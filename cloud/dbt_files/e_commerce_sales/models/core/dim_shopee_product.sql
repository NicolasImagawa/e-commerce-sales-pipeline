{{
    config(
        materialized='incremental',
        unique_key='product_id',
        incremental_strategy='merge',
        database=target.database
    )
}}

WITH product_id_sku AS(
 SELECT product_id,
        SPLIT_PART(product_id, 'SH_', 2) AS sku,
		MAX(ld_timestamp) AS ld_timestamp
	FROM {{ ref("shopee_orders_results") }}
	GROUP BY product_id,
	         sku
), new_data AS (
    SELECT product_id_sku.product_id AS product_id,
           stg_shopee.numero_de_referencia_sku AS sku,
           kit_components.product AS product,
           product_id_sku.ld_timestamp
        FROM product_id_sku,
             {{ ref("stg_shopee") }} AS stg_shopee,
             {{ source("supplies", "kit_components") }} AS kit_components
        WHERE product_id_sku.sku = stg_shopee.numero_de_referencia_sku
		    AND product_id_sku.sku = kit_components.sku
			AND stg_shopee.numero_de_referencia_sku = kit_components.sku
            {% if is_incremental() %}
                AND  product_id_sku.ld_timestamp  > (SELECT MAX(ld_timestamp) FROM {{ this }})
            {% endif %}
        GROUP BY product_id_sku.product_id,
           		 stg_shopee.numero_de_referencia_sku,
           		 kit_components.product,
				 product_id_sku.ld_timestamp
)
    SELECT  product_id,
            sku,
            product,
            ld_timestamp
    FROM new_data
 
