-- tests/no_duplicate_policy_keys.sql

select policy_id
from {{ ref('int_policies_dedup') }}
group by policy_id
having count(*) > 1