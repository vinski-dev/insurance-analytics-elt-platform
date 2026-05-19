-- tests/no_negative_claim_amounts.sql

select *
from {{ ref('fct_claims') }}
where claim_amount < 0