{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge'
    )
}}

WITH add_timestamp AS (
	SELECT ml.buyer__id,
           ml.id,
		   ml._dlt_id,
           CURRENT_TIMESTAMP AS ld_timestamp
	FROM {{ source("entry_ml", "stg_mercadolivre") }} AS ml

), buyers AS (
	SELECT DISTINCT add_timestamp.buyer__id,
		   add_timestamp._dlt_id,
           add_timestamp.ld_timestamp
	FROM add_timestamp

    {% if is_incremental() %}
        WHERE add_timestamp.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }}) /*the "this" keyword compares to shopee_orders_results table*/
    {% endif %}

), product_sku_qt_price_fee AS (
		SELECT DISTINCT orders.item__title AS product,
                orders.item__seller_sku AS sku,
                orders.quantity AS qt,
                orders.unit_price AS price,
                orders.sale_fee AS fee,
                orders._dlt_parent_id AS _dlt_parent_id
			FROM {{ source("entry_ml", "stg_mercadolivre__order_items") }} AS orders
), agg_results AS (
	SELECT payments.order_id,
		   orders.item__seller_sku AS sku,
		   SUM(payments.transaction_amount) AS agg_transaction_amount,
		   SUM(payments.shipping_cost) AS agg_sh_cost,
           add_timestamp.ld_timestamp
	FROM {{ source("entry_ml", "stg_mercadolivre__payments") }} AS payments
    LEFT JOIN {{ source("entry_ml", "stg_mercadolivre__order_items") }} AS orders
        ON payments._dlt_parent_id = orders._dlt_parent_id
    LEFT JOIN add_timestamp
        ON payments.order_id = add_timestamp.id
    WHERE payments.date_approved IS NOT NULL
    {% if is_incremental() %}

        AND ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

    {% endif %}

	GROUP BY payments.order_id,
		     orders.item__seller_sku,
             add_timestamp.ld_timestamp
), order_date AS (
	SELECT payments.order_id,
		   MAX(payments.date_approved) AS date_paid,
		   orders.unit_price AS price,
	   	   orders.item__seller_sku AS sku,
           add_timestamp.ld_timestamp
	FROM {{ source("entry_ml", "stg_mercadolivre__payments") }} AS payments
    LEFT JOIN {{ source("entry_ml", "stg_mercadolivre__order_items") }} AS orders
        ON orders._dlt_parent_id = payments._dlt_parent_id
    LEFT JOIN add_timestamp
        ON payments.order_id = add_timestamp.id
    {% if is_incremental() %}

        WHERE add_timestamp.ld_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }})

    {% endif %}
    GROUP BY payments.order_id,
            orders.unit_price,
            orders.item__seller_sku,
            add_timestamp.ld_timestamp

), orders_costs AS (
		SELECT order_date.order_id,
			   kit.sku,
			   order_date.date_paid,
			   order_date.price,
			   SUM(costs.cost) AS total_prod_cost
	FROM {{ source("supplies", "kit_components") }} AS kit, 
		 {{ source("supplies", "product_sku_cost") }} AS costs,
		 order_date
	WHERE kit.component_sku = costs.sku
		AND kit.sku = order_date.sku
		AND (costs.end_date >= order_date.date_paid OR costs.end_date IS NULL)
		AND costs.begin_date <= order_date.date_paid
	GROUP BY order_date.order_id,
			 order_date.date_paid,
			 order_date.price,
			 kit.sku
), prep_seller_sh_cost AS (
	SELECT ml.id AS order_id,
		   COALESCE(ml_sh.lead_time__list_cost__v_double, 0) AS seller_ship_cost,
		   orders_costs.price
	FROM {{ source("entry_ml", "stg_mercadolivre_sh") }} AS ml_sh
	LEFT JOIN {{ source("entry_ml", "stg_mercadolivre") }} AS ml
		ON ml_sh.id = ml.shipping__id
	LEFT JOIN orders_costs
		ON orders_costs.order_id = ml.id
	GROUP BY ml.id,
			 seller_ship_cost,
			 price
), aux_seller_sh_cost AS (
	SELECT prep_seller_sh_cost.order_id AS order_id,
		   prep_seller_sh_cost.seller_ship_cost AS seller_ship_cost,
		   orders_costs.price
		FROM prep_seller_sh_cost
		INNER JOIN orders_costs
			ON orders_costs.order_id = prep_seller_sh_cost.order_id
		WHERE orders_costs.price >= 79.00 --2000009590300714
), seller_sh_cost AS (
	SELECT prep_seller_sh_cost.order_id,
		   COALESCE(aux_seller_sh_cost.seller_ship_cost, 0) AS seller_ship_cost,
		   prep_seller_sh_cost.price
		FROM prep_seller_sh_cost
		LEFT JOIN aux_seller_sh_cost
			ON prep_seller_sh_cost.order_id = aux_seller_sh_cost.order_id
), new_results AS (
		SELECT  payments.id AS main_id,
                CONCAT('ML_', {{ dbt_utils.generate_surrogate_key(['buyers.buyer__id', 'payments.date_approved']) }} ) AS main_buyer__id,
                payments.order_id,
                CONCAT('ML_', product_sku_qt_price_fee.sku) AS product_id,
                CONCAT('ML_', {{ dbt_utils.generate_surrogate_key(['payments.id', 'payments.date_approved']) }} ) AS date_id,
                payments.date_approved,
                payments.payment_method_id,
                product_sku_qt_price_fee.qt,
                payments.total_paid_amount,
                payments.transaction_amount,
                product_sku_qt_price_fee.price,
                COALESCE(payments.shipping_cost, 0) AS sh_cost,
                product_sku_qt_price_fee.fee,
                orders_costs.total_prod_cost,
		        seller_sh_cost.seller_ship_cost,
                ROUND(CAST(agg_results.agg_transaction_amount - (product_sku_qt_price_fee.qt * (product_sku_qt_price_fee.fee + orders_costs.total_prod_cost)) - seller_sh_cost.seller_ship_cost AS NUMERIC), 2) AS profit,
                buyers.ld_timestamp
            FROM {{ source("entry_ml", "stg_mercadolivre__payments") }} AS payments,
                 product_sku_qt_price_fee,
                 buyers,
                 agg_results,
                 orders_costs,
                 seller_sh_cost
            WHERE product_sku_qt_price_fee.product = payments.reason
             AND  payments._dlt_parent_id = product_sku_qt_price_fee._dlt_parent_id
             AND  buyers._dlt_id = payments._dlt_parent_id
             AND  payments.order_id = agg_results.order_id
			 AND  payments.order_id = orders_costs.order_id
             AND  orders_costs.sku = agg_results.sku
			 AND  product_sku_qt_price_fee.sku = orders_costs.sku
			 AND  product_sku_qt_price_fee.sku = agg_results.sku
             AND  seller_sh_cost.order_id = orders_costs.order_id
			 AND  seller_sh_cost.order_id = payments.order_id
			 AND  seller_sh_cost.order_id = agg_results.order_id
             AND  payments.status = 'approved'
            {% if is_incremental() %}

                AND payments.id IN (SELECT main_id FROM {{ this }})

            {% endif %}
), update_results AS (
		SELECT  new_results.main_id,
                new_results.main_buyer__id,
                new_results.order_id,
                new_results.product_id,
                new_results.date_id,
                new_results.payment_method_id,
                new_results.qt,
                new_results.total_paid_amount,
                new_results.transaction_amount,
                new_results.price,
                new_results.sh_cost,
                new_results.fee,
                new_results.total_prod_cost,
		        new_results.seller_ship_cost,
                new_results.profit,
                new_results.ld_timestamp
            FROM new_results
            {% if is_incremental() %}

                WHERE new_results.main_id IN (SELECT main_id FROM {{ this }})

            {% endif %}
), insert_results AS (
		SELECT  new_results.main_id,
                new_results.main_buyer__id,
                new_results.order_id,
                new_results.product_id,
                new_results.date_id,
                new_results.payment_method_id,
                new_results.qt,
                new_results.total_paid_amount,
                new_results.transaction_amount,
                new_results.price,
                new_results.sh_cost,
                new_results.fee,
                new_results.total_prod_cost,
		        new_results.seller_ship_cost,
                new_results.profit,
                new_results.ld_timestamp
            FROM new_results
            WHERE new_results.main_id NOT IN (SELECT main_id FROM update_results)
) SELECT main_id,
       main_buyer__id,
       order_id,
       product_id,
       date_id,
       payment_method_id,
       qt,
       total_paid_amount,
       transaction_amount,
       price,
       sh_cost,
       fee,
       total_prod_cost,
       seller_ship_cost,
       profit,
       ld_timestamp
    FROM update_results
UNION
SELECT main_id,
       main_buyer__id,
       order_id,
       product_id,
       date_id,
       payment_method_id,
       qt,
       total_paid_amount,
       transaction_amount,
       price,
       sh_cost,
       fee,
       total_prod_cost,
       seller_ship_cost,
       profit,
       ld_timestamp
    FROM insert_results
