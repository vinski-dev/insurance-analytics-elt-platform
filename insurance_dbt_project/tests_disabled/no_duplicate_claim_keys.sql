-- tests/no_duplicate_claim_keys.sql

select claim_id
from {{ ref('int_claims_dedup') }}
group by claim_id
having count(*) > 1