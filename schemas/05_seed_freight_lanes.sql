WITH lanes AS (
  SELECT * FROM (VALUES
    ('JAX1','ATL1','Linehaul Express', 345.0, 360),
    ('TPA1','ATL1','Regional Freight Co', 420.0, 450),
    ('ATL1','NAS1','Linehaul Express', 250.0, 270),
    ('NAS1','IND1','Linehaul Express', 300.0, 330),
    ('IND1','CHI1','Linehaul Express', 185.0, 210),
    ('CHI1','STL1','Regional Freight Co', 300.0, 330),
    ('STL1','COL1','Linehaul Express', 410.0, 450),
    ('COL1','CLE1','Regional Freight Co', 140.0, 165),
    ('CLE1','PIT1','Regional Freight Co', 135.0, 150),
    ('PIT1','CLT1','Linehaul Express', 450.0, 520),
    ('CLT1','ATL1','Linehaul Express', 245.0, 270),
    ('IND1','COL1','RailBridge', 175.0, 300)
  ) AS v(o_code,d_code,carrier,distance_miles,planned_minutes)
)
INSERT INTO dim_lane (origin_node_id, dest_node_id, carrier_id, distance_miles, planned_minutes)
SELECT o.node_id, d.node_id, c.carrier_id, l.distance_miles, l.planned_minutes
FROM lanes l
JOIN dim_node o ON o.node_code = l.o_code
JOIN dim_node d ON d.node_code = l.d_code
JOIN dim_carrier c ON c.carrier_name = l.carrier
ON CONFLICT DO NOTHING;
