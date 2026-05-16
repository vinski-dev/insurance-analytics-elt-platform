-- models/marts/mart_claims_daily_kpi.sql
-- Purpose:
-- Daily business KPI mart for dashboards.

SELECT
    event_date,
    claim_count,
    distinct_claim_count,
    total_claim_amount,
    avg_claim_amount,
    approved_claim_count,
    rejected_claim_count,
    pending_claim_count,
    closed_claim_count,
    approved_claim_count / NULLIF(claim_count, 0) AS approval_rate,
    rejected_claim_count / NULLIF(claim_count, 0) AS rejection_rate,
    pending_claim_count / NULLIF(claim_count, 0) AS pending_rate
FROM {{ ref('int_claims_daily') }}