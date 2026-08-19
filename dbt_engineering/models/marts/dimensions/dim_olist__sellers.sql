with sellers as (

    select
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state

    from {{ ref('stg_olist__sellers') }}

),

final as (

    select
        s.seller_id,
        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state,
        g.latitude as seller_latitude,
        g.longitude as seller_longitude

    from sellers as s

    left join {{ ref('int_olist__geolocation_enriched') }} as g
        on s.seller_zip_code_prefix =
           g.geolocation_zip_code_prefix

)

select *
from final