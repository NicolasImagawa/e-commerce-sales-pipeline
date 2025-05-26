{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy='merge'
    )
}}

WITH new_data AS (
    SELECT orders_results.product_id AS product_id,
           stg_shopee.nome_do_produto AS product_ad_name,
           stg_shopee.numero_de_referencia_sku AS sku,
           kit_components.product AS product,
           orders_results.ld_timestamp AS ld_timestamp
        FROM {{ ref("shopee_orders_results") }} AS orders_results,
             {{ source("entry_shopee", "stg_shopee") }} AS stg_shopee,
             {{ source("supplies", "kit_components") }} AS kit_components,
             {{ ref("shopee_new_id") }} AS shopee_new_id
        WHERE orders_results.main_id = shopee_new_id.main_id
            AND shopee_new_id.id_do_pedido = stg_shopee.id_do_pedido
            AND stg_shopee.numero_de_referencia_sku = kit_components.sku
            {% if is_incremental() %}
                AND orders_results.ld_timestamp  > (SELECT MAX(ld_timestamp) FROM {{ this }})
            {% endif %}
), update_data AS (
        SELECT  product_id,
                product_ad_name,
                sku,
                product,
                ld_timestamp
        FROM new_data
            {% if is_incremental() %}
                WHERE product_id IN (SELECT product_id FROM {{ this }})
            {% endif %}
), insert_data AS (
        SELECT  product_id,
                product_ad_name,
                sku,
                product,
                ld_timestamp
        FROM new_data
        WHERE product_id NOT IN (SELECT product_id FROM update_data)
) SELECT product_id,
         product_ad_name,
         sku,
         product,
         ld_timestamp
    FROM update_data
    UNION
    SELECT product_id,
           product_ad_name,
           sku,
           product,
           ld_timestamp
    FROM insert_data
