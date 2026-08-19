with order_items as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        carrier_handover_deadline,
        price,
        shipping_cost

    from {{ ref('stg_olist__order_items') }}

),

products as (

    select
        product_id,
        product_category_name_pt,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from {{ ref('stg_olist__products') }}

),

sellers as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state

    from {{ ref('stg_olist__sellers') }}

),

product_category_names as (

    select
        product_category_name_pt,
        product_category_name_english

    from {{ ref('stg_olist__product_category_name') }}

),

manual_translations as (

    select
        column1::varchar as product_category_name_pt,
        column2::varchar as product_category_name_english

    from values
        ('pc_gamer', 'pc gaming'),
        (
            'portateis_cozinha_e_preparados_de_alimentos',
            'portable kitchen and food preparation'
        )

),

order_items_enriched as (

    select
        oi.order_id,
        oi.order_item_id,
        oi.product_id,
        oi.seller_id,
        oi.carrier_handover_deadline,
        oi.price,
        oi.shipping_cost,

        round(
            oi.price + oi.shipping_cost,
            2
        ) as total_price,

        case
            when p.product_category_name_pt is null
                then 'Unknown'
            else coalesce(
                mt.product_category_name_english,
                c.product_category_name_english,
                'Untranslated'
            )
        end as product_category_name,

        p.product_name_length,
        p.product_description_length,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,

        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state

    from order_items as oi

    left join products as p
        on oi.product_id = p.product_id

    left join sellers as s
        on oi.seller_id = s.seller_id

    left join product_category_names as c
        on p.product_category_name_pt =
           c.product_category_name_pt

    left join manual_translations as mt
        on p.product_category_name_pt =
           mt.product_category_name_pt

)

select *
from order_items_enriched