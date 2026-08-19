with geolocation as (

    select
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng
    from {{ ref('stg_olist__geolocation') }}

),

geolocation_by_zip as (

    select
        geolocation_zip_code_prefix,
        median(geolocation_lat) as latitude,
        median(geolocation_lng) as longitude
    from geolocation
    group by geolocation_zip_code_prefix

)

select *
from geolocation_by_zip