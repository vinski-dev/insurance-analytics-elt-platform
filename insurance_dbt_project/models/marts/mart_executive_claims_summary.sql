-- models/marts/mart_executive_claims_summary.sql
-- Purpose:
-- Single-row executive KPI summary.

SELECT
    COUNT(*) AS total_claims,
    COUNT(DISTINCT policy_id) AS policies_with_claims,
    COUNT(DISTINCT customer_id) AS customers_with_claims,
    SUM(claim_amount) AS total_claim_amount,
    AVG(claim_amount) AS avg_claim_amount,

    SUM(CASE WHEN claim_status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_claims,
    SUM(CASE WHEN claim_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_claims,
    SUM(CASE WHEN claim_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_claims,
    SUM(CASE WHEN claim_status = 'CLOSED' THEN 1 ELSE 0 END) AS closed_claims,

    SUM(CASE WHEN claim_status = 'APPROVED' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS approval_rate,
    SUM(CASE WHEN claim_status = 'REJECTED' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS rejection_rate,

    MIN(event_date) AS earliest_claim_date,
    MAX(event_date) AS latest_claim_date
FROM {{ ref('fct_claims') }}
