-- models/marts/mart_policy_claims_kpi.sql
-- Purpose:
-- Policy-level KPI mart.
-- This is loss-ratio-ready once policy premium data is available.

SELECT
    policy_id,
    claim_count,
    total_claim_amount,
    avg_claim_amount,
    max_claim_amount,
    first_claim_date,
    latest_claim_date,
    approved_claim_amount,
    rejected_claim_amount,

    approved_claim_amount / NULLIF(total_claim_amount, 0) AS approved_claim_amount_rate
FROM {{ ref('int_claims_policy') }};
