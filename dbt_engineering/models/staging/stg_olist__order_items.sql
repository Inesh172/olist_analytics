with 

source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date as carrier_handover_deadline,
        price,
        freight_value as shipping_cost

    from source

)

select * from renamed