-- joining customers and orders table for purchase timestamp
with customer_orders as (

    select
        c.customer_id,
        c.order_customer_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        o.order_id,
        o.order_purchase_timestamp

    from {{ ref('stg_olist__customers') }} as c

    left join {{ ref('stg_olist__orders') }} as o
        on c.order_customer_id = o.order_customer_id

),

-- ranking based on most recent order purchase for each customer
ranked_customers as (

    select
        *,
        row_number() over (
            partition by customer_id
            order by
                order_purchase_timestamp desc nulls last,
                order_id desc
        ) as customer_record_sequence

    from customer_orders

),

-- using the location of the most recent order of each customer to showcase their individual locations
final as (

    select
        c.customer_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        g.latitude as customer_latitude,
        g.longitude as customer_longitude

    from ranked_customers as c

    left join {{ ref('int_olist__geolocation_enriched') }} as g
        on c.customer_zip_code_prefix =
           g.geolocation_zip_code_prefix

    where c.customer_record_sequence = 1

)

select *
from final