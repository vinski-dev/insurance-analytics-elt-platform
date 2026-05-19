{{ config(materialized='view') }}

select
    policy_id,
    customer_id,
    policy_type,
    premium_amount,
    policy_status,
    updated_at,
    ingestion_time
from {{ source('raw', 'policies_raw') }}