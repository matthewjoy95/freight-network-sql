DO $$
DECLARE
  v_n      INT  := 5000;
  v_prefix TEXT := 'FRTZ-';
BEGIN
  WITH wh AS (
    SELECT node_id
    FROM dim_node
    WHERE node_type='warehouse'
  ),
  picks AS (
    SELECT gs AS seq
    FROM generate_series(1, v_n) gs
  ),
  od AS (
    SELECT
      p.seq,
      o.node_id AS origin_node_id,
      d.node_id AS dest_node_id
    FROM picks p
    CROSS JOIN LATERAL (SELECT node_id FROM wh ORDER BY random() LIMIT 1) o
    CROSS JOIN LATERAL (SELECT node_id FROM wh ORDER BY random() LIMIT 1) d
    WHERE o.node_id <> d.node_id
  )
  INSERT INTO fact_shipment (
    shipment_ref, created_at, origin_node_id, dest_node_id,
    priority, promised_at, current_status, declared_value_usd, weight_lbs
  )
  SELECT
    v_prefix || lpad(seq::text, 6, '0'),
    NOW() - (random()*60 || ' days')::interval,
    origin_node_id,
    dest_node_id,
    (CASE WHEN random() < 0.10 THEN 'critical'
          WHEN random() < 0.30 THEN 'expedite'
          ELSE 'standard' END),
    NOW() + interval '3 days' + (random()*interval '12 hours'),
    'created',
    ROUND((50 + random()*950)::numeric,2),
    ROUND((5 + random()*195)::numeric,2)
  FROM od;

  INSERT INTO fact_shipment_event (shipment_id, event_ts, node_id, event_type)
  SELECT shipment_id, created_at, origin_node_id, 'created'
  FROM fact_shipment
  WHERE shipment_ref LIKE v_prefix || '%';

  INSERT INTO fact_shipment_event (shipment_id, event_ts, node_id, event_type)
  SELECT shipment_id, created_at + interval '30 minutes', origin_node_id, 'picked_up'
  FROM fact_shipment
  WHERE shipment_ref LIKE v_prefix || '%';

  INSERT INTO fact_shipment_event (shipment_id, event_ts, node_id, event_type)
  SELECT shipment_id, created_at + interval '2 days', (SELECT node_id FROM dim_node WHERE node_code='CUST'), 'delivered'
  FROM fact_shipment
  WHERE shipment_ref LIKE v_prefix || '%';

  UPDATE fact_shipment
  SET delivered_at = created_at + interval '2 days',
      current_status = 'delivered'
  WHERE shipment_ref LIKE v_prefix || '%';
END $$;
