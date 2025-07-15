{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge',
        database=target.database
    )
}}

WITH shipping_id AS (
    SELECT order_status.main_id,
           stg_mercadolivre.shipping__id AS shipping_id,
           stg_mercadolivre.fulfilled,
           order_status.ld_timestamp
        FROM {{ ref('mercadolivre_orders_results') }} AS order_status
        LEFT JOIN {{ ref('stg_mercadolivre') }} AS stg_mercadolivre
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
        LEFT JOIN {{ ref('stg_mercadolivre_sh') }} AS stg_mercadolivre_sh
            ON shipping_id.shipping_id = stg_mercadolivre_sh.id
)
    SELECT  status_data.main_id,
            status_data.shipping_id,
            status_data.fulfilled,
            status_data.status,
            status_data.delivery_id,
            status_data.delivery_method,
            status_data.ld_timestamp
        FROM status_data