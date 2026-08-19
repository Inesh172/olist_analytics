with 

source as (

    select * from {{ source('olist', 'order_reviews') }}

),

renamed as (

    select
        review_id,
        order_id,
        review_score as satisfaction_score,
        review_comment_title,
        review_comment_message,
        review_creation_date as survey_issued_at,
        review_answer_timestamp as survey_submitted_at

    from source

)

select * from renamed