-- models/intermediate/int_claims_policy.sql
-- Purpose:
-- Create policy-level claim behavior metrics.
-- This is useful for future loss ratio joins if you later add policy premium data.

SELECT
    policy_id,
    COUNT(*) AS claim_count,
    SUM(claim_amount) AS total_claim_amount,
    AVG(claim_amount) AS avg_claim_amount,
    MAX(claim_amount) AS max_claim_amount,
    MIN(event_date) AS first_claim_date,
    MAX(event_date) AS latest_claim_date,
    SUM(CASE WHEN claim_status = 'APPROVED' THEN claim_amount ELSE 0 END) AS approved_claim_amount,
    SUM(CASE WHEN claim_status = 'REJECTED' THEN claim_amount ELSE 0 END) AS rejected_claim_amount
FROM {{ ref('int_claims_latest') }}
GROUP BY policy_id;
