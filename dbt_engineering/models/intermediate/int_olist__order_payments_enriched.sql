with payments as (

    select
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from {{ ref('stg_olist__order_payments') }}

    where not (
        payment_type = 'not_defined'
        and payment_value = 0
    )

)

select *
from payments