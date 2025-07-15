{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key="load_id",
    )
}}

WITH max_timestamp AS (SELECT CURRENT_TIMESTAMP AS load_timestamp)
, new_data AS (
    SELECT  CONCAT(ml.id, order_items.item__seller_sku) AS load_id,
            order_items.item__id, 
            order_items.item__title, 
            order_items.item__category_id, 
            order_items.item__warranty, 
            order_items.item__condition, 
            order_items.item__seller_sku, 
            order_items.quantity, 
            order_items.unit_price, 
            order_items.full_unit_price,
            order_items.requested_quantity__measure,
            order_items.requested_quantity__value, 
            order_items.sale_fee, 
            order_items.listing_type_id, 
            order_items.element_id, 
            order_items._dlt_parent_id, 
            order_items._dlt_list_idx, 
            order_items._dlt_id, 
            order_items.item__variation_id,
            max_timestamp.load_timestamp
        FROM {{ source("entry_ml", "entry_mercadolivre__order_items") }} AS order_items, 
             {{ source("entry_ml", "entry_mercadolivre") }} AS ml,
             max_timestamp
        WHERE order_items._dlt_parent_id = ml._dlt_id
        {% if is_incremental() %}
            AND max_timestamp.load_timestamp > (SELECT MAX(load_timestamp ) FROM {{this}})
        {% endif %}
) SELECT * FROM new_data

