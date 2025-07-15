{{
    config(
        materialized='incremental',
        unique_key='product_ad_id',
        incremental_strategy='merge',
        database=target.database
    )
}}

WITH ad_name AS (
    SELECT orders_results.product_id AS product_id,
           orders_results.order_id AS order_id,
           stg_mercadolivre__payments.reason AS product_ad_name,
           orders_results.ld_timestamp AS ld_timestamp
        FROM {{ ref('mercadolivre_orders_results') }} AS orders_results
        LEFT JOIN {{ ref('stg_mercadolivre__payments') }} AS stg_mercadolivre__payments
            ON orders_results.order_id = stg_mercadolivre__payments.order_id
        LEFT JOIN {{ ref('stg_mercadolivre') }} AS stg_mercadolivre
            ON orders_results.order_id = stg_mercadolivre.id
        {% if is_incremental() %}

            WHERE orders_results.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

        {% endif %}
), ad_name_dlt_id AS (
    SELECT ad_name.product_id,
           ad_name.product_ad_name,
           stg_mercadolivre._dlt_id AS dlt_id,
           ad_name.ld_timestamp
        FROM ad_name
        LEFT JOIN {{ ref('stg_mercadolivre') }} AS stg_mercadolivre
            ON ad_name.order_id = stg_mercadolivre.id
), ad_name_dlt_id_sku AS (
    SELECT ad_name_dlt_id.product_id,
           ad_name_dlt_id.product_ad_name,
           stg_mercadolivre__order_items.item__seller_sku AS sku,
           ad_name_dlt_id.dlt_id,
           ad_name_dlt_id.ld_timestamp
        FROM ad_name_dlt_id
        LEFT JOIN {{ ref('stg_mercadolivre__order_items') }} AS stg_mercadolivre__order_items
            ON ad_name_dlt_id.dlt_id = stg_mercadolivre__order_items._dlt_parent_id
), ad_name_dlt_id_sku_product AS (
    SELECT ad_name_dlt_id_sku.product_id,
           CONCAT('ML_', {{ dbt_utils.generate_surrogate_key(['ad_name_dlt_id_sku.product_id', 'ad_name_dlt_id_sku.product_ad_name']) }} ) AS product_ad_id,
           ad_name_dlt_id_sku.product_ad_name,
           ad_name_dlt_id_sku.sku,
           kit_components.product,
           ad_name_dlt_id_sku.ld_timestamp
        FROM ad_name_dlt_id_sku
        LEFT JOIN {{ source('supplies', 'kit_components') }} AS kit_components
            ON ad_name_dlt_id_sku.sku = kit_components.sku
        GROUP BY ad_name_dlt_id_sku.product_id,
                 product_ad_id,
	             ad_name_dlt_id_sku.product_ad_name,
	             ad_name_dlt_id_sku.sku,
	             kit_components.product,
	             ad_name_dlt_id_sku.ld_timestamp
)
    SELECT ad_name_dlt_id_sku_product.product_id,
           ad_name_dlt_id_sku_product.product_ad_id,
           ad_name_dlt_id_sku_product.product_ad_name,
           ad_name_dlt_id_sku_product.sku,
           ad_name_dlt_id_sku_product.product,
           ad_name_dlt_id_sku_product.ld_timestamp
        FROM ad_name_dlt_id_sku_product
