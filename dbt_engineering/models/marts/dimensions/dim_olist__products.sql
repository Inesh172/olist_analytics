with products as (

    select distinct
        product_id,
        product_category_name,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm

    from {{ ref('int_olist__order_items_enriched') }}

)

select *
from products