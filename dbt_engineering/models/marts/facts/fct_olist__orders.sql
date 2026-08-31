with orders as (

    select *
    from {{ ref('int_olist__orders_enriched') }}

),

final as (

    select
        orders.*,

        cast(
            order_purchase_timestamp as date
        ) as order_purchase_date

    from orders

)

select *
from final