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
), update_data AS (
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
        {% if is_incremental() %}

            WHERE date_approved_estimated_delivery.date_id IN (SELECT date_id FROM {{ this }})

        {% endif %}
), insert_data AS (
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
    WHERE date_approved_estimated_delivery.date_id NOT IN (SELECT date_id FROM update_data)

) SELECT update_data.date_id,
         update_data.date_approved,
         update_data.year_approved,
         update_data.month_approved,
         update_data.day_approved,
         update_data.estimated_delivery_date,
         update_data.year_delivered,
         update_data.month_delivered,
         update_data.day_delivered,
         update_data.ld_timestamp
    FROM update_data
    UNION
  SELECT insert_data.date_id,
         insert_data.date_approved,
         insert_data.year_approved,
         insert_data.month_approved,
         insert_data.day_approved,
         insert_data.estimated_delivery_date,
         insert_data.year_delivered,
         insert_data.month_delivered,
         insert_data.day_delivered,
         insert_data.ld_timestamp
    FROM insert_data