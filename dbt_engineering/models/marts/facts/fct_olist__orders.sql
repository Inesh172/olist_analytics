with orders as (

    select 
        order_id,
        order_customer_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        purchase_to_carrier_days,
        carrier_to_customer_days,
        actual_delivery_days,
        delivery_variance_days,
        is_late_delivery
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