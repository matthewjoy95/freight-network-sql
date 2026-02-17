-- Pick ~20% of shipments to become late
WITH late AS (
  SELECT shipment_id
  FROM fact_shipment
  ORDER BY random()
  LIMIT (SELECT (COUNT(*) * 0.20)::int FROM fact_shipment)
),
bump AS (
  SELECT
    shipment_id,
    (interval '1 hour' + random() * interval '12 hours') AS late_by
  FROM late
)
-- 1) push delivered EVENT later
UPDATE fact_shipment_event e
SET event_ts = event_ts + b.late_by
FROM bump b
WHERE e.shipment_id = b.shipment_id
  AND e.event_type = 'delivered';

-- 2) keep fact_shipment.delivered_at consistent with delivered EVENT
UPDATE fact_shipment s
SET delivered_at = e.event_ts
FROM fact_shipment_event e
WHERE s.shipment_id = e.shipment_id
  AND e.event_type = 'delivered';

-- 3) add a delay_reported event for late shipments (optional but nice)
INSERT INTO fact_shipment_event (shipment_id, event_ts, node_id, event_type, delay_reason_id, delay_minutes, notes)
SELECT
  s.shipment_id,
  e.event_ts - interval '3 hours',
  s.dest_node_id,
  'delay_reported',
  (SELECT delay_reason_id FROM dim_delay_reason ORDER BY random() LIMIT 1),
  (60 + floor(random()*240))::int,
  'Synthetic delay added for realism'
FROM fact_shipment s
JOIN fact_shipment_event e
  ON e.shipment_id = s.shipment_id
 AND e.event_type = 'delivered'
WHERE e.event_ts > s.promised_at
ON CONFLICT DO NOTHING;
