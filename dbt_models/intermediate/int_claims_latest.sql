-- models/intermediate/int_claims_latest.sql
-- Purpose:
-- Produce the latest version of every claim.
-- RAW remains append-only, but this model removes duplicate/replayed claim records.

WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY claim_id
            ORDER BY updated_at DESC, ingestion_time DESC, source_file_name DESC
        ) AS rn
    FROM {{ ref('stg_claims') }}
)

SELECT
    claim_id,
    policy_id,
    customer_id,
    claim_amount,
    claim_status,
    event_date,
    updated_at,
    batch_id,
    ingestion_time,
    source_file_name
FROM ranked
WHERE rn = 1;
