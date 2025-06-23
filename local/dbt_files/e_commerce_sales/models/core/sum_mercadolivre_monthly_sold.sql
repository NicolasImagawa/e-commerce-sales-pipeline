{{
    config(materialized="view")
}}

WITH product_sku AS (
	SELECT product.product,
	       product.product_id
	FROM {{ ref("dim_mercadolivre_product") }} AS product
	GROUP BY product.product,
	         product.product_id
) SELECT MAKE_DATE(CAST(dim_date.year_approved AS INT), CAST(dim_date.month_approved AS INT), 1) AS "month",
	     product_sku.product AS product_name,
		 COUNT(results.product_id) AS sales_qt
   FROM {{ ref("mercadolivre_orders_results") }} AS results, 
        product_sku,
	    {{ ref("dim_mercadolivre_date") }} AS dim_date
WHERE product_sku.product_id = results.product_id
AND results.date_id = dim_date.date_id
GROUP BY product_sku.product, "month"
ORDER BY "month"