INSERT INTO dim_node (node_code, node_name, node_type, city, state, timezone) VALUES
  ('PIT1','Pittsburgh DC','warehouse','Pittsburgh','PA','America/New_York'),
  ('CLE1','Cleveland DC','warehouse','Cleveland','OH','America/New_York'),
  ('COL1','Columbus Crossdock','crossdock','Columbus','OH','America/New_York'),
  ('IND1','Indianapolis Hub','hub','Indianapolis','IN','America/New_York'),
  ('CHI1','Chicago Hub','hub','Chicago','IL','America/Chicago'),
  ('STL1','St. Louis Crossdock','crossdock','St. Louis','MO','America/Chicago'),
  ('NAS1','Nashville DC','warehouse','Nashville','TN','America/Chicago'),
  ('ATL1','Atlanta Hub','hub','Atlanta','GA','America/New_York'),
  ('CLT1','Charlotte DC','warehouse','Charlotte','NC','America/New_York'),
  ('JAX1','Jacksonville DC','warehouse','Jacksonville','FL','America/New_York'),
  ('TPA1','Tampa DC','warehouse','Tampa','FL','America/New_York'),
  ('CUST','Customer','customer','—','—','America/New_York')
ON CONFLICT DO NOTHING;

INSERT INTO dim_carrier (carrier_name, mode) VALUES
  ('Linehaul Express','truck'),
  ('Regional Freight Co','truck'),
  ('RailBridge','rail')
ON CONFLICT DO NOTHING;

INSERT INTO dim_delay_reason (reason_code, reason_desc) VALUES
  ('WX','Weather'),
  ('MECH','Mechanical'),
  ('CAP','Capacity constraint'),
  ('OPS','Operational backlog'),
  ('APPT','Delivery appointment missed'),
  ('CUST','Customer not available')
ON CONFLICT DO NOTHING;
