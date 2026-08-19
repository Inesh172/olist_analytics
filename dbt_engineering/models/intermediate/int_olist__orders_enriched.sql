with orders as (

    select
        order_id,
        order_customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date

    from {{ ref('stg_olist__orders') }}

),

customers as (

    select
        order_customer_id,
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state

    from {{ ref('stg_olist__customers') }}

),

orders_enriched as (

    select
        o.order_id,
        o.order_customer_id,
        c.customer_id,

        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,

        case
            when o.order_purchase_timestamp is not null
             and o.order_delivered_carrier_date is not null
                then datediff(
                    'day',
                    o.order_purchase_timestamp,
                    o.order_delivered_carrier_date
                )
            else null
        end as purchase_to_carrier_days,

        case
            when o.order_delivered_carrier_date is not null
             and o.order_delivered_customer_date is not null
                then datediff(
                    'day',
                    o.order_delivered_carrier_date,
                    o.order_delivered_customer_date
                )
            else null
        end as carrier_to_customer_days,

        case
            when o.order_purchase_timestamp is not null
             and o.order_delivered_customer_date is not null
                then datediff(
                    'day',
                    o.order_purchase_timestamp,
                    o.order_delivered_customer_date
                )
            else null
        end as actual_delivery_days,

        case
            when o.order_status = 'delivered'
             and o.order_delivered_customer_date is not null
             and o.order_estimated_delivery_date is not null
                
            then datediff(
                 'day',
                 o.order_estimated_delivery_date,
                 o.order_delivered_customer_date
            )
            
            else null
        end as delivery_variance_days,

        case
            when o.order_status <> 'delivered'
                then null

            when o.order_delivered_customer_date is null
             or o.order_estimated_delivery_date is null
                then null

            when cast(o.order_delivered_customer_date as date)
            > cast(o.order_estimated_delivery_date as date)
                then true

            else false
        end as is_late_delivery,

        case
            when o.order_status = 'delivered'
             and o.order_approved_at is null
                then true
            else false
        end as is_approval_timestamp_missing,

        case
            when o.order_status = 'delivered'
             and o.order_delivered_carrier_date is null
                then true
            else false
        end as is_carrier_timestamp_missing,

        case
            when o.order_status = 'delivered'
             and o.order_delivered_customer_date is null
                then true
            else false
        end as is_customer_delivery_timestamp_missing        

    from orders as o

    left join customers as c
        on o.order_customer_id = c.order_customer_id

)

select *
from orders_enriched