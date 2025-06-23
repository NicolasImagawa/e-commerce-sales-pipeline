{{
    config(
        materialized="view"
    )
}}

SELECT MAKE_DATE(CAST(dim_date.year_approved AS INT), CAST(dim_date.month_approved AS INT), 1) AS "month",
	   ROUND(SUM(results.qt * CAST(results.price AS NUMERIC)), 2)
	FROM {{ ref("shopee_orders_results") }} AS results,
		 {{ ref("dim_shopee_date") }} AS dim_date
	WHERE results.date_id = dim_date.date_id
	GROUP BY "month"
	ORDER BY "month"