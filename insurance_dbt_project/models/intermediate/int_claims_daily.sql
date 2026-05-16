-- models/intermediate/int_claims_daily.sql
-- Purpose:
-- Aggregate claim metrics by event_date for trend analysis.

SELECT
    event_date,
    COUNT(*) AS claim_count,
    COUNT(DISTINCT claim_id) AS distinct_claim_count,
    SUM(claim_amount) AS total_claim_amount,
    AVG(claim_amount) AS avg_claim_amount,
    SUM(CASE WHEN claim_status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_claim_count,
    SUM(CASE WHEN claim_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_claim_count,
    SUM(CASE WHEN claim_status = 'PENDING' THEN 1 ELSE 0 END) AS pending_claim_count,
    SUM(CASE WHEN claim_status = 'CLOSED' THEN 1 ELSE 0 END) AS closed_claim_count
FROM {{ ref('int_claims_latest') }}
GROUP BY event_date
