{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge'
    )
}}

WITH new_data AS (
    SELECT  id_do_pedido,
            numero_de_referencia_sku AS sku,
            CONCAT(id_do_pedido, numero_de_referencia_sku) AS main_id,
            MAX(load_timestamp) AS load_timestamp /*Protects against duplicates on the staging table*/
    FROM {{ ref('stg_shopee') }}

    {% if is_incremental() %}

        WHERE load_timestamp > (SELECT MAX(load_timestamp) FROM {{ this }})

    {% endif %}
    GROUP BY id_do_pedido,
             sku,
             main_id
), update_data AS (
    SELECT  id_do_pedido,
            sku,
            main_id,
            load_timestamp
        FROM new_data

    {% if is_incremental() %}

        WHERE main_id IN (SELECT main_id FROM {{ this }})

    {% endif %}
), insert_data AS (
    SELECT  id_do_pedido,
            sku,
            main_id,
            load_timestamp
        FROM new_data
        WHERE main_id NOT IN (SELECT main_id FROM update_data)

) SELECT id_do_pedido,
         sku,
         main_id,
         load_timestamp
        FROM update_data
    UNION
  SELECT id_do_pedido,
         sku,
         main_id,
         load_timestamp
        FROM insert_data
