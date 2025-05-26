WITH order_date AS (
	SELECT main_id,
		   date_created AS date_paid,
	   	   sku
	FROM shopee.orders_results
), orders_cost AS (
	SELECT order_date.main_id,
	   kit.sku,
	   order_date.date_paid,
	   SUM(costs.cost) AS total_prod_cost
	FROM mercadolivre.kit_components AS kit, 
		 mercadolivre.product_sku_cost AS costs,
		 order_date
	WHERE kit.component_sku = costs.sku
		AND kit.sku = order_date.sku
		AND (costs.end_date >= order_date.date_paid OR costs.end_date IS NULL)
		AND costs.begin_date <= order_date.date_paid
	GROUP BY order_date.main_id,
			 order_date.date_paid,
			 kit.sku
), insert_profits AS (
	SELECT  orders_results.main_id,
			orders_results.buyer__id,
			orders_results.date_created,
			orders_results.date_approved,
			orders_results.product,
			orders_results.sku,
			orders_results.qt,
			orders_results.price,
			orders_results.unit_comission_fee,
			orders_results.unit_service_fee,
			orders_results.sh_cost,
			orders_results.sh_discount,
			orders_results.reverse_sh_fee,
			orders_results.refund_status,
			orders_cost.total_prod_cost,
			(orders_results.price - orders_results.unit_comission_fee - orders_results.unit_service_fee - orders_cost.total_prod_cost) - orders_results.reverse_sh_fee AS profit
		FROM shopee.orders_results AS orders_results
		LEFT JOIN orders_cost
			ON orders_results.sku = orders_cost.sku
			AND orders_results.main_id = orders_cost.main_id
) INSERT INTO shopee.profits (
        main_id,
        buyer__id,
        date_created,
        date_approved,
        product,
        sku,
        qt,
        price,
        unit_comission_fee,
        unit_service_fee,
        sh_cost,
        sh_discount,
        reverse_sh_fee,
        refund_status,
        total_cost,
        profit
    )  	SELECT  insert_profits.main_id,
                insert_profits.buyer__id,
                insert_profits.date_created,
                insert_profits.date_approved,
                insert_profits.product,
                insert_profits.sku,
                insert_profits.qt,
                insert_profits.price,
                insert_profits.unit_comission_fee,
                insert_profits.unit_service_fee,
                insert_profits.sh_cost,
                insert_profits.sh_discount,
                insert_profits.reverse_sh_fee,
                insert_profits.refund_status,
                insert_profits.total_prod_cost,
                insert_profits.profit
            FROM insert_profits
        ON CONFLICT (main_id)
        DO UPDATE SET main_id = EXCLUDED.main_id,
                    buyer__id = EXCLUDED.buyer__id,
                    date_created = EXCLUDED.date_created,
                    date_approved = EXCLUDED.date_approved,
                    product = EXCLUDED.product,
                    sku = EXCLUDED.sku,
                    qt = EXCLUDED.qt,
                    price = EXCLUDED.price,
                    unit_comission_fee = EXCLUDED.unit_comission_fee,
                    unit_service_fee = EXCLUDED.unit_service_fee,
                    sh_cost = EXCLUDED.sh_cost,
                    sh_discount = EXCLUDED.sh_discount,
                    reverse_sh_fee = EXCLUDED.reverse_sh_fee,
                    refund_status = EXCLUDED.refund_status,
                    total_cost = EXCLUDED.total_cost,
                    profit = EXCLUDED.profit
