-- models/marts/mart_customer_claims_kpi.sql
-- Purpose:
-- Customer-level KPI mart for segmentation and risk analysis.

SELECT
    customer_id,
    claim_count,
    total_claim_amount,
    avg_claim_amount,
    max_claim_amount,
    first_claim_date,
    latest_claim_date,
    approved_claim_count,
    rejected_claim_count,
    approved_claim_count / NULLIF(claim_count, 0) AS approval_rate,
    rejected_claim_count / NULLIF(claim_count, 0) AS rejection_rate,
    CASE
        WHEN total_claim_amount >= 50000 THEN 'HIGH_CLAIM_VALUE'
        WHEN total_claim_amount >= 15000 THEN 'MEDIUM_CLAIM_VALUE'
        ELSE 'LOW_CLAIM_VALUE'
    END AS claim_value_segment
FROM {{ ref('int_claims_customer') }}