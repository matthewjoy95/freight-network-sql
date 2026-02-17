# Freight Network SQL Analytics

A simulated freight logistics network built in PostgreSQL, modeling shipments, nodes, and shipment events to calculate SLA (on-time delivery) performance.

This project demonstrates SQL data modeling, data generation, and analytics on logistics-style data.

---

## Tech Stack
- PostgreSQL
- Docker
- SQL (CTEs, aggregations, analytics queries)

---

## Data Model

The warehouse includes:

- `dim_node` – network locations (warehouses, customer node)
- `dim_lane` – origin/destination relationships
- `fact_shipment` – shipments with priority, promise dates, and weights
- `fact_shipment_event` – shipment lifecycle events (created, picked_up, delivered)

---

## What this project does

1. Generates a realistic freight network with:
   - 5,000 shipments
   - 15,000+ shipment events

2. Simulates delivery timelines and SLA targets

3. Calculates **on-time delivery performance by priority level**

---

## Key Analytics Example

SLA on-time delivery rate by shipment priority:

```
priority   | shipments | pct_on_time
-----------+-----------+------------
critical   | 473       | 100.00
expedite   | 1299      | 100.00
standard   | 3228      | 100.00
```

Late delivery check:

```
total | late
------+------
5000  | 885
```

---

## How to run locally

1. Start database:

```bash
docker compose up -d
```

2. Seed schema + generate data:

```bash
docker exec -i freight_sql_db psql -U freight -d freightdb < schemas/10_generate_freight.sql
```

3. Run analytics:

```bash
docker exec -i freight_sql_db psql -U freight -d freightdb < queries/04_analytics/01_sla_on_time.sql
```

4. Run validation tests:

```bash
docker exec -i freight_sql_db psql -U freight -d freightdb < tests/04_business_rules.sql
```

---

## Business Questions Answered

- What % of shipments meet SLA by priority?
- How many shipments are late?
- Are any shipments invalid (same origin/destination)?

---

## Why this project matters

This project simulates a real-world logistics analytics environment and demonstrates:

- dimensional modeling
- event-based fact tables
- SLA performance analytics
- data quality validation with SQL

---

## Author

Matthew Joy  
BSBA, University of Florida  
Aspiring data / robotics / systems engineer
