# Analytics Layer Guide

## Architecture

Python → Snowflake RAW → dbt staging → dbt intermediate → dbt marts

## RAW layer

Table:

- `INSURANCE_DW.RAW.CLAIMS_RAW`

Purpose:

- Append-only landing table
- Stores source records exactly after Python validation
- Includes audit columns:
  - `batch_id`
  - `ingestion_time`
  - `source_file_name`

## Staging layer

Model:

- `stg_claims`

Purpose:

- Standardizes column names and data types
- Applies basic business validity filters
- Does not perform heavy business logic

## Intermediate layer

Models:

- `int_claims_latest`
- `int_claims_daily`
- `int_claims_customer`
- `int_claims_policy`

Purpose:

- Handles reusable transformation logic
- Deduplicates latest claim version
- Builds reusable daily, customer, and policy aggregations

## Mart layer

Models:

- `fct_claims`
- `mart_claims_daily_kpi`
- `mart_customer_claims_kpi`
- `mart_policy_claims_kpi`
- `mart_executive_claims_summary`

Purpose:

- Business-ready analytics tables
- Used by dashboards, analysts, actuarial users, and reporting

## Main KPIs

- Total claims
- Distinct claims
- Total claim amount
- Average claim amount
- Approval rate
- Rejection rate
- Pending rate
- Customer claim value segment
- Policy-level total claim amount
- Loss-ratio-ready policy output

## Interview pitch

I keep RAW append-only for auditability. Staging handles typing and light cleaning. Intermediate models contain reusable business logic such as deduplication and claim-level aggregations. Mart models expose business-ready KPIs for dashboards and actuarial analytics.
