with payments as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value

    from {{ ref('int_olist__order_payments_enriched') }}

)

select *
from payments