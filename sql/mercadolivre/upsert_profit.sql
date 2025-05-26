WITH agg_results AS (
	SELECT order_id,
		   sku,
		   SUM(transaction_amount) AS agg_transaction_amount,
		   SUM(sh_cost) AS agg_sh_cost
	FROM mercadolivre.orders_results
	GROUP BY order_id,
		   sku
), order_date AS (
	SELECT order_id,
		   date_approved AS date_paid,
		   orders_results.price,
	   	   sku
	FROM mercadolivre.orders_results
), orders_costs AS (
		SELECT order_date.order_id,
			   kit.sku,
			   order_date.date_paid,
			   order_date.price,
			   SUM(costs.cost) AS total_prod_cost
	FROM mercadolivre.kit_components AS kit, 
		 mercadolivre.product_sku_cost AS costs,
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
		   orders_costs.total_prod_cost AS total_prod_cost
	FROM mercadolivre.mercadolivre_sh AS ml_sh
	LEFT JOIN mercadolivre.mercadolivre AS ml
		ON ml_sh.id = ml.shipping__id
	LEFT JOIN orders_costs
		ON orders_costs.order_id = ml.id
	GROUP BY ml.id,
			 seller_ship_cost,
			 total_prod_cost
), aux_seller_sh_cost AS (
	SELECT prep_seller_sh_cost.order_id AS order_id,
		   prep_seller_sh_cost.seller_ship_cost AS seller_ship_cost,
		   orders_costs.total_prod_cost AS total_prod_cost
		FROM prep_seller_sh_cost
		INNER JOIN orders_costs
			ON orders_costs.order_id = prep_seller_sh_cost.order_id
		WHERE orders_costs.total_prod_cost >= 79.00 --2000009590300714
), seller_sh_cost AS (
	SELECT prep_seller_sh_cost.order_id,
		   COALESCE(aux_seller_sh_cost.seller_ship_cost, 0) AS seller_ship_cost,
		   prep_seller_sh_cost.total_prod_cost
		FROM prep_seller_sh_cost
		LEFT JOIN aux_seller_sh_cost
			ON prep_seller_sh_cost.order_id = aux_seller_sh_cost.order_id
), results_agg AS (
	SELECT orders_results.order_id,
		   orders_results.product,
		   orders_results.sku,
		   MAX(orders_results.date_approved) AS date_approved, /*Since the sell price might appear with two values for the same order, the last one is chosen*/
		   orders_results.qt,
		   MAX(orders_results.total_paid_amount) AS total_paid_amount,  /*Since the sell price might appear with two values for the same order, the last one is chosen*/
		   agg_results.agg_transaction_amount,
		   orders_results.price,
		   agg_results.agg_sh_cost,
		   orders_results.fee,
		   orders_costs.total_prod_cost,
		   seller_sh_cost.seller_ship_cost,
		   ROUND(CAST(agg_results.agg_transaction_amount - (orders_results.qt * (orders_results.fee + orders_costs.total_prod_cost)) - seller_ship_cost AS NUMERIC), 2) AS profit
	 FROM mercadolivre.orders_results AS orders_results
	 LEFT JOIN agg_results
		 ON orders_results.order_id = agg_results.order_id
		 AND orders_results.sku = agg_results.sku
	 LEFT JOIN orders_costs
		 ON orders_results.sku = orders_costs.sku
		 AND orders_results.order_id = orders_costs.order_id
	 LEFT JOIN seller_sh_cost
		 ON orders_results.order_id = seller_sh_cost.order_id
	 GROUP BY orders_results.order_id,
		   orders_results.product,
		   orders_results.sku,
		   orders_results.qt,
		   agg_results.agg_transaction_amount,
		   orders_results.price,
		   agg_results.agg_sh_cost,
		   orders_results.fee,
		   orders_costs.total_prod_cost,
		   seller_sh_cost.seller_ship_cost,
		   profit
) INSERT INTO mercadolivre.profits (
	order_id,
	product,
	sku,
	date_approved,
	qt,
	total_paid_amount,
	agg_transaction_amount,
	price,
	agg_sh_cost,
	fee,
	product_cost,
	seller_ship_cost,
	profit
) SELECT results_agg.order_id,
		 results_agg.product,
		 results_agg.sku,
		 results_agg.date_approved,
		 results_agg.qt,
		 results_agg.total_paid_amount,
		 results_agg.agg_transaction_amount,
		 results_agg.price,
		 results_agg.agg_sh_cost,
		 results_agg.fee,
		 results_agg.total_prod_cost,
		 results_agg.seller_ship_cost,
		 results_agg.profit
	FROM results_agg
ON CONFLICT (order_id)
DO UPDATE SET order_id = EXCLUDED.order_id,
              	product = EXCLUDED.product,
				sku = EXCLUDED.sku,
				date_approved = EXCLUDED.date_approved,
				qt = EXCLUDED.qt,
				total_paid_amount = EXCLUDED.total_paid_amount,
				agg_transaction_amount = EXCLUDED.agg_transaction_amount,
				price = EXCLUDED.price,
				agg_sh_cost = EXCLUDED.agg_sh_cost,
				fee = EXCLUDED.fee,
				product_cost = EXCLUDED.product_cost,
				seller_ship_cost = EXCLUDED.seller_ship_cost,
				profit = EXCLUDED.profit