with reviews as (

    select
        review_id,
        order_id,
        satisfaction_score,
        review_comment_title,
        review_comment_message,
        survey_issued_at,
        survey_submitted_at
    from {{ ref('stg_olist__order_reviews') }}

),

reviews_enriched as (

    select
        review_id,
        order_id,
        satisfaction_score,
        review_comment_title,
        review_comment_message,

        nullif(
            trim(
                regexp_replace(
                    concat(
                        coalesce(review_comment_title, ''),
                        ' ',
                        coalesce(review_comment_message, '')
                    ),
                    '\\s+',
                    ' '
                )
            ),
            ''
        ) as review_text_pt,

        survey_issued_at,
        survey_submitted_at,

        row_number() over (
            partition by order_id
            order by
                survey_submitted_at desc nulls last,
                survey_issued_at desc nulls last,
                review_id desc
        ) as review_sequence

    from reviews

),

final as (

    select
        review_id,
        order_id,
        satisfaction_score,
        review_comment_title,
        review_comment_message,
        review_text_pt,
        survey_issued_at,
        survey_submitted_at,

        case
            when review_sequence = 1 then true
            else false
        end as is_latest_review

    from reviews_enriched

)

select *
from final