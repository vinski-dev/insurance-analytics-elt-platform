-- models/marts/core/dim_policies.sql

{{ config(materialized='table') }}

select
    policy_id,
    customer_id,
    policy_type,
    policy_status,
    premium_amount,
    updated_at
from {{ ref('int_policies_dedup') }}