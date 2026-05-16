-- dbt model: models/marts/fct_claims.sql

{{ config(
    materialized='incremental',
    unique_key='claim_id'
) }}

SELECT
    claim_id,
    policy_id,
    customer_id,
    claim_amount,
    claim_status,
    event_date,
    updated_at,
    ingestion_time,
    source_file_name
FROM {{ ref('stg_claims') }}

{% if is_incremental() %}
WHERE updated_at >= DATEADD(day, -2, (
    SELECT COALESCE(MAX(updated_at), '1900-01-01')
    FROM {{ this }}
))
{% endif %}
