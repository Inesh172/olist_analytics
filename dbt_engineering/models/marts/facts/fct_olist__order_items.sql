with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        carrier_handover_deadline,
        price,
        shipping_cost,
        total_price

    from {{ ref('int_olist__order_items_enriched') }}

)

select *
from order_items