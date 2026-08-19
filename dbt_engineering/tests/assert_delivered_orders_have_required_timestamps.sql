{{ config(severity =  'warn') }}

select
    order_id,
    order_status,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date

from {{ ref('fct_olist__orders') }}

where order_status = 'delivered'
    and (
         order_approved_at is null
         or order_delivered_carrier_date is null
         or order_delivered_customer_date is null
        )