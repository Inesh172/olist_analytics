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

order_items_by_order as (

    select
        order_id,
        round(sum(price), 2) as item_subtotal,
        round(sum(shipping_cost), 2) as shipping_total,
        round(sum(total_price), 2) as order_total_amount

    from {{ ref('int_olist__order_items_enriched') }}

    group by order_id

),

payments_by_order as (

    select
        order_id,
        round(sum(payment_value), 2) as total_payment_value

    from {{ ref('int_olist__order_payments_enriched') }}

    group by order_id

),

final as (

    select
        o.*,

        cast(order_purchase_timestamp as date) as order_purchase_date,
        coalesce(oi.item_subtotal, 0) as item_subtotal,
        coalesce(oi.shipping_total, 0) as shipping_total,
        coalesce(oi.order_total_amount, 0) as order_total_amount,
        coalesce(p.total_payment_value, 0) as total_payment_value

    from orders as o

    left join order_items_by_order as oi
        on o.order_id = oi.order_id

    left join payments_by_order as p
        on o.order_id = p.order_id

)

select *
from final