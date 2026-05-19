-- tests/no_multiple_current_policy_versions.sql

select policy_id
from {{ ref('policies_scd') }}
where dbt_valid_to is null
group by policy_id
having count(*) > 1