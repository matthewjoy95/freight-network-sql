-- Logistics / Freight Network (PostgreSQL)

CREATE TABLE IF NOT EXISTS dim_node (
  node_id        SERIAL PRIMARY KEY,
  node_code      TEXT NOT NULL UNIQUE,
  node_name      TEXT NOT NULL,
  node_type      TEXT NOT NULL CHECK (node_type IN ('warehouse','hub','port','crossdock','customer')),
  city           TEXT,
  state          TEXT,
  country        TEXT NOT NULL DEFAULT 'US',
  timezone       TEXT NOT NULL DEFAULT 'America/New_York',
  is_active      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS dim_carrier (
  carrier_id     SERIAL PRIMARY KEY,
  carrier_name   TEXT NOT NULL UNIQUE,
  mode           TEXT NOT NULL CHECK (mode IN ('truck','rail','air','ocean'))
);

CREATE TABLE IF NOT EXISTS dim_lane (
  lane_id           SERIAL PRIMARY KEY,
  origin_node_id    INT NOT NULL REFERENCES dim_node(node_id),
  dest_node_id      INT NOT NULL REFERENCES dim_node(node_id),
  carrier_id        INT NOT NULL REFERENCES dim_carrier(carrier_id),
  distance_miles    NUMERIC(10,2) NOT NULL CHECK (distance_miles >= 0),
  planned_minutes   INT NOT NULL CHECK (planned_minutes > 0),
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE (origin_node_id, dest_node_id, carrier_id)
);

CREATE TABLE IF NOT EXISTS dim_delay_reason (
  delay_reason_id  SERIAL PRIMARY KEY,
  reason_code      TEXT NOT NULL UNIQUE,
  reason_desc      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_shipment (
  shipment_id        BIGSERIAL PRIMARY KEY,
  shipment_ref       TEXT NOT NULL UNIQUE,
  created_at         TIMESTAMP NOT NULL DEFAULT NOW(),
  origin_node_id     INT NOT NULL REFERENCES dim_node(node_id),
  dest_node_id       INT NOT NULL REFERENCES dim_node(node_id),
  priority           TEXT NOT NULL CHECK (priority IN ('standard','expedite','critical')),
  promised_at        TIMESTAMP NOT NULL,
  delivered_at       TIMESTAMP,
  current_status     TEXT NOT NULL CHECK (current_status IN ('created','in_transit','at_facility','delayed','delivered','cancelled')),
  declared_value_usd NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (declared_value_usd >= 0),
  weight_lbs         NUMERIC(12,2) NOT NULL CHECK (weight_lbs > 0)
);

CREATE TABLE IF NOT EXISTS fact_shipment_plan_stop (
  shipment_id     BIGINT NOT NULL REFERENCES fact_shipment(shipment_id) ON DELETE CASCADE,
  stop_seq        INT NOT NULL CHECK (stop_seq > 0),
  node_id         INT NOT NULL REFERENCES dim_node(node_id),
  planned_arrive  TIMESTAMP,
  planned_depart  TIMESTAMP,
  PRIMARY KEY (shipment_id, stop_seq)
);

CREATE TABLE IF NOT EXISTS fact_shipment_event (
  shipment_event_id  BIGSERIAL PRIMARY KEY,
  shipment_id        BIGINT NOT NULL REFERENCES fact_shipment(shipment_id) ON DELETE CASCADE,
  event_ts           TIMESTAMP NOT NULL,
  node_id            INT REFERENCES dim_node(node_id),
  event_type         TEXT NOT NULL CHECK (event_type IN (
    'created','picked_up','departed','arrived','out_for_delivery',
    'delivered','exception','delay_reported','cancelled'
  )),
  lane_id            INT REFERENCES dim_lane(lane_id),
  delay_reason_id    INT REFERENCES dim_delay_reason(delay_reason_id),
  delay_minutes      INT CHECK (delay_minutes >= 0),
  notes              TEXT
);
