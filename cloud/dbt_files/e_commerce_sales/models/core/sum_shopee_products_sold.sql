{{
    config(
		materialized="view"
	)
}}

WITH product_sku AS (
	SELECT product.product,
	       product.product_id
	FROM {{ ref("dim_shopee_product") }} AS product
	GROUP BY product.product,
	         product.product_id
) SELECT CAST((EXTRACT(YEAR FROM date_approved) || '/' || EXTRACT(MONTH FROM date_approved) || '/01') AS DATE) AS "month",
	     product_sku.product AS product_name,
		 COUNT(results.product_id) AS sales_qt
   FROM {{ ref("shopee_orders_results") }} AS results, 
        product_sku,
	    {{ ref("dim_shopee_date") }} AS dim_date
WHERE product_sku.product_id = results.product_id
AND results.date_id = dim_date.date_id
GROUP BY product_sku.product, "month"
ORDER BY "month"