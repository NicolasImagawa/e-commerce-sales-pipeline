{{
    config(
        materialized='incremental',
        unique_key='date_id',
        incremental_strategy='merge',
        database=target.database
    )
}}

WITH date_approved AS (
    SELECT orders_results.date_id,
           stg_mercadolivre__payments.date_approved,
           orders_results.order_id,
           orders_results.ld_timestamp
        FROM {{ ref('mercadolivre_orders_results') }} AS orders_results
            LEFT JOIN {{ ref('stg_mercadolivre__payments') }} AS stg_mercadolivre__payments
            ON orders_results.main_id = stg_mercadolivre__payments.id
        {% if is_incremental() %}

            WHERE orders_results.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}
), date_approved_ship_id AS (
    SELECT date_approved.date_id,
           date_approved.date_approved,
           date_approved.order_id,
           stg_mercadolivre.shipping__id AS shipping_id,
           date_approved.ld_timestamp
        FROM date_approved
            LEFT JOIN {{ ref('stg_mercadolivre') }} AS stg_mercadolivre
            ON date_approved.order_id = stg_mercadolivre.id
), date_approved_estimated_delivery AS (
    SELECT date_approved_ship_id.date_id,
           date_approved_ship_id.date_approved,
           EXTRACT( YEAR FROM date_approved_ship_id.date_approved) AS year_approved,
           EXTRACT( MONTH FROM date_approved_ship_id.date_approved) AS month_approved,
           EXTRACT( DAY FROM date_approved_ship_id.date_approved) AS day_approved,
           stg_mercadolivre_sh.lead_time__estimated_delivery_limit__date AS estimated_delivery_date,
           EXTRACT( YEAR FROM stg_mercadolivre_sh.lead_time__estimated_delivery_limit__date) AS year_delivered,
           EXTRACT( MONTH FROM stg_mercadolivre_sh.lead_time__estimated_delivery_limit__date) AS month_delivered,
           EXTRACT( DAY FROM stg_mercadolivre_sh.lead_time__estimated_delivery_limit__date) AS day_delivered,
           date_approved_ship_id.ld_timestamp
    FROM date_approved_ship_id
        LEFT JOIN {{ ref('stg_mercadolivre_sh') }} AS stg_mercadolivre_sh
        ON date_approved_ship_id.shipping_id = stg_mercadolivre_sh.id
)
    SELECT  date_approved_estimated_delivery.date_id,
            date_approved_estimated_delivery.date_approved,
            date_approved_estimated_delivery.year_approved,
            date_approved_estimated_delivery.month_approved,
            date_approved_estimated_delivery.day_approved,
            date_approved_estimated_delivery.estimated_delivery_date,
            date_approved_estimated_delivery.year_delivered,
            date_approved_estimated_delivery.month_delivered,
            date_approved_estimated_delivery.day_delivered,
            date_approved_estimated_delivery.ld_timestamp
    FROM date_approved_estimated_delivery
