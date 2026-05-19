-- tests/claims_have_valid_policy.sql

select c.policy_id
from {{ ref('fct_claims') }} c
left join {{ ref('dim_policies') }} p
  on c.policy_id = p.policy_id
where p.policy_id is null