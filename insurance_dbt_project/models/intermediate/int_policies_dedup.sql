-- models/intermediate/int_policies_dedup.sql

{{ config(materialized='incremental', unique_key='policy_id') }}

with ranked as (
    select
        *,
        row_number() over (
            partition by policy_id
            order by updated_at desc, ingestion_time desc
        ) as rn
    from {{ ref('stg_policies') }}

    {% if is_incremental() %}
    where updated_at >= dateadd(
        day,
        -{{ var('lookback_days', 7) }},
        current_timestamp()
    )
    {% endif %}
)

select
    policy_id,
    customer_id,
    policy_type,
    premium_amount,
    policy_status,
    updated_at,
    ingestion_time
from ranked
where rn = 1