-- tests/no_zero_premium_loss_ratio.sql

select *
from {{ ref('fct_loss_ratio') }}
where total_premium = 0