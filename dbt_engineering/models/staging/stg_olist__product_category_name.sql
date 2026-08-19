with 

source as (

    select * from {{ source('olist', 'product_category_name') }}

),

renamed as (

    select
        product_category_name as product_category_name_pt,
        product_category_name_english

    from source

)

select * from renamed