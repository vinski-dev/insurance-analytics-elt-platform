-- models/staging/stg_claims.sql
-- Purpose:
-- 1. Standardize raw column names and data types
-- 2. Keep only valid/usable business records
-- 3. Preserve ingestion metadata for auditability

WITH source AS (
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
    FROM {{ source('raw', 'claims_raw') }}
),

typed AS (
    SELECT
        claim_id::STRING AS claim_id,
        policy_id::STRING AS policy_id,
        customer_id::STRING AS customer_id,
        claim_amount::NUMBER(12,2) AS claim_amount,
        claim_status::STRING AS claim_status,
        event_date::DATE AS event_date,
        updated_at::TIMESTAMP_NTZ AS updated_at,
        batch_id::STRING AS batch_id,
        ingestion_time::TIMESTAMP_NTZ AS ingestion_time,
        source_file_name::STRING AS source_file_name
    FROM source
    WHERE claim_id IS NOT NULL
      AND policy_id IS NOT NULL
      AND customer_id IS NOT NULL
      AND claim_amount >= 0
      AND claim_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CLOSED')
)

SELECT *
FROM typed
