{{
    config(
        materialized="view"
    )
}}

SELECT CAST((EXTRACT(YEAR FROM date_approved) || '/' || EXTRACT(MONTH FROM date_approved) || '/01') AS DATE) AS "month",
	   ROUND(SUM(results.qt * results.profit), 2)
	FROM {{ ref("shopee_orders_results") }} AS results,
		 {{ ref("dim_shopee_date") }} AS dim_date
	WHERE results.date_id = dim_date.date_id
	GROUP BY "month"
	ORDER BY "month"