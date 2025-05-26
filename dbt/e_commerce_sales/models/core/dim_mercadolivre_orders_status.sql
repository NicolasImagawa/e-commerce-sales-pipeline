{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge'
    )
}}

WITH shipping_id AS (
    SELECT order_status.main_id,
           stg_mercadolivre.shipping__id AS shipping_id,
           stg_mercadolivre.fulfilled,
           order_status.ld_timestamp
        FROM {{ ref('mercadolivre_orders_results') }} AS order_status
        LEFT JOIN {{ source('entry_ml', 'stg_mercadolivre') }} AS stg_mercadolivre
            ON order_status.order_id = stg_mercadolivre.id
        {% if is_incremental() %}

            WHERE order_status.ld_timestamp >(SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}
), status_data AS (
    SELECT shipping_id.main_id,
           shipping_id.shipping_id,
           shipping_id.fulfilled,
           stg_mercadolivre_sh.status,
           stg_mercadolivre_sh.tracking_number AS delivery_id,
           stg_mercadolivre_sh.lead_time__shipping_method__type AS delivery_method,
           shipping_id.ld_timestamp
        FROM shipping_id
        LEFT JOIN {{ source('entry_ml', 'stg_mercadolivre_sh') }} AS stg_mercadolivre_sh
            ON shipping_id.shipping_id = stg_mercadolivre_sh.id
), update_data AS (
    SELECT  status_data.main_id,
            status_data.shipping_id,
            status_data.fulfilled,
            status_data.status,
            status_data.delivery_id,
            status_data.delivery_method,
            status_data.ld_timestamp
        FROM status_data
        {% if is_incremental() %}

            WHERE status_data.main_id IN (SELECT main_id FROM {{ this }})

        {% endif %}
), insert_data AS (
    SELECT  status_data.main_id,
            status_data.shipping_id,
            status_data.fulfilled,
            status_data.status,
            status_data.delivery_id,
            status_data.delivery_method,
            status_data.ld_timestamp
        FROM status_data
        WHERE status_data.main_id NOT IN (SELECT main_id FROM update_data)
)
SELECT update_data.main_id,
       update_data.shipping_id,
       update_data.fulfilled,
       update_data.status,
       update_data.delivery_id,
       update_data.delivery_method,
       update_data.ld_timestamp
    FROM update_data
UNION
SELECT insert_data.main_id,
       insert_data.shipping_id,
       insert_data.fulfilled,
       insert_data.status,
       insert_data.delivery_id,
       insert_data.delivery_method,
       insert_data.ld_timestamp
    FROM insert_data
