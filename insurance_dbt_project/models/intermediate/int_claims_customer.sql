-- models/intermediate/int_claims_customer.sql
-- Purpose:
-- Create customer-level claim behavior metrics.

SELECT
    customer_id,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_claim_amount,
    AVG(claim_amount) AS avg_claim_amount,
    MAX(claim_amount) AS max_claim_amount,
    MIN(event_date) AS first_claim_date,
    MAX(event_date) AS latest_claim_date,
    SUM(CASE WHEN claim_status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_claim_count,
    SUM(CASE WHEN claim_status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_claim_count
FROM {{ ref('int_claims_latest') }}
GROUP BY customer_id
