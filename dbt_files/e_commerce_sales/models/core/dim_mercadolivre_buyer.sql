{{
    config(
        materialized='incremental',
        unique_key='main_buyer__id',
        incremental_strategy='merge'
    )
}}

WITH buyer_id_shipping_id AS (
    SELECT orders_results.main_buyer__id,
           stg_mercadolivre.buyer__id,
           stg_mercadolivre.shipping__id,
           stg_mercadolivre.buyer__nickname,
           orders_results.ld_timestamp
        FROM {{ ref('mercadolivre_orders_results') }} AS orders_results
        LEFT JOIN {{ source('entry_ml', 'stg_mercadolivre') }} AS stg_mercadolivre
            ON orders_results.order_id = stg_mercadolivre.id
        {% if is_incremental() %}

            WHERE orders_results.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}

), buyer_id_shipping_id_buyer_data AS (
    SELECT buyer_id_shipping_id.main_buyer__id,
           buyer_id_shipping_id.buyer__id,
           buyer_id_shipping_id.buyer__nickname,
           stg_mercadolivre_sh.destination__receiver_name AS receiver_name,
           stg_mercadolivre_sh.destination__shipping_address__street_name AS street,
           stg_mercadolivre_sh.destination__shipping_address__street_number AS street_number,
           stg_mercadolivre_sh.destination__shipping_address__comment AS additional_info,
           stg_mercadolivre_sh.destination__shipping_address__zip_code AS zip_code,
           stg_mercadolivre_sh.destination__shipping_address__neighborhood__name AS neighborhood,
           stg_mercadolivre_sh.destination__shipping_address__city__name AS city_town,
           stg_mercadolivre_sh.destination__shipping_address__state__name AS state,
           stg_mercadolivre_sh.destination__shipping_address__country__id AS country,
           buyer_id_shipping_id.ld_timestamp
        FROM buyer_id_shipping_id
        LEFT JOIN {{ source('entry_ml', 'stg_mercadolivre_sh') }} AS stg_mercadolivre_sh
            ON buyer_id_shipping_id.shipping__id = stg_mercadolivre_sh.id
), update_data AS (
    SELECT buyer_id_shipping_id_buyer_data.main_buyer__id,
           buyer_id_shipping_id_buyer_data.buyer__id,
           buyer_id_shipping_id_buyer_data.buyer__nickname,
           buyer_id_shipping_id_buyer_data.receiver_name,
           buyer_id_shipping_id_buyer_data.street,
           buyer_id_shipping_id_buyer_data.street_number,
           buyer_id_shipping_id_buyer_data.additional_info,
           buyer_id_shipping_id_buyer_data.zip_code,
           buyer_id_shipping_id_buyer_data.neighborhood,
           buyer_id_shipping_id_buyer_data.city_town,
           buyer_id_shipping_id_buyer_data.state,
           buyer_id_shipping_id_buyer_data.country,
           buyer_id_shipping_id_buyer_data.ld_timestamp
        FROM buyer_id_shipping_id_buyer_data
        {% if is_incremental() %}

            WHERE buyer_id_shipping_id_buyer_data.buyer__id IN (SELECT buyer__id FROM {{ this }})

        {% endif %}
), insert_data AS (
    SELECT buyer_id_shipping_id_buyer_data.main_buyer__id,
           buyer_id_shipping_id_buyer_data.buyer__id,
           buyer_id_shipping_id_buyer_data.buyer__nickname,
           buyer_id_shipping_id_buyer_data.receiver_name,
           buyer_id_shipping_id_buyer_data.street,
           buyer_id_shipping_id_buyer_data.street_number,
           buyer_id_shipping_id_buyer_data.additional_info,
           buyer_id_shipping_id_buyer_data.zip_code,
           buyer_id_shipping_id_buyer_data.neighborhood,
           buyer_id_shipping_id_buyer_data.city_town,
           buyer_id_shipping_id_buyer_data.state,
           buyer_id_shipping_id_buyer_data.country,
           buyer_id_shipping_id_buyer_data.ld_timestamp
        FROM buyer_id_shipping_id_buyer_data
        WHERE buyer_id_shipping_id_buyer_data.buyer__id NOT IN (SELECT buyer__id FROM update_data)
) SELECT update_data.main_buyer__id,
         update_data.buyer__id,
         update_data.buyer__nickname,
         update_data.receiver_name,
         update_data.street,
         update_data.street_number,
         update_data.additional_info,
         update_data.zip_code,
         update_data.neighborhood,
         update_data.city_town,
         update_data.state,
         update_data.country,
         update_data.ld_timestamp
    FROM update_data
    UNION
    SELECT insert_data.main_buyer__id,
           insert_data.buyer__id,
           insert_data.buyer__nickname,
           insert_data.receiver_name,
           insert_data.street,
           insert_data.street_number,
           insert_data.additional_info,
           insert_data.zip_code,
           insert_data.neighborhood,
           insert_data.city_town,
           insert_data.state,
           insert_data.country,
           insert_data.ld_timestamp
    FROM insert_data