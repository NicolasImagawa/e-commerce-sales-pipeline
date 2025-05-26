CREATE TABLE IF NOT EXISTS  mercadolivre.profits (
    order_id BIGINT UNIQUE NOT NULL,
	product VARCHAR(200),
	sku VARCHAR(30),
    date_approved TIMESTAMP WITH TIME ZONE,
    qt INT,
	total_paid_amount NUMERIC(7,2),
    agg_transaction_amount NUMERIC(7,2),
    price NUMERIC(7,2),
    agg_sh_cost NUMERIC(4,2),
    fee NUMERIC(6,2),
	seller_ship_cost NUMERIC(6,2),
    product_cost NUMERIC(7,2),
	profit NUMERIC(6,2)
)

/*Aux query*/
WITH agg_results AS (
	SELECT order_id,
		   sku,
		   SUM(transaction_amount) AS agg_transaction_amount,
		   SUM(sh_cost) AS agg_sh_cost
	FROM mercadolivre.orders_results
	GROUP BY order_id,
		   sku
), sku_cost AS (
   SELECT product_sku_cost.sku,
          product_sku_cost.total_cost
   FROM mercadolivre.product_sku_cost AS product_sku_cost
   GROUP BY product_sku_cost.sku,
            product_sku_cost.total_cost
), orders_results_cost_agg AS (
	SELECT orders_results.order_id,
		   orders_results.product,
		   orders_results.sku,
		   orders_results.date_approved,
		   orders_results.qt,
		   agg_results.agg_transaction_amount,
		   orders_results.price,
		   agg_results.agg_sh_cost,
		   orders_results.fee,
		   sku_cost.total_cost
	 FROM mercadolivre.orders_results AS orders_results
	 LEFT JOIN agg_results
		 ON orders_results.order_id = agg_results.order_id
		 AND orders_results.sku = agg_results.sku
	 LEFT JOIN sku_cost
		 ON orders_results.sku = sku_cost.sku
) SELECT * FROM orders_results_cost_agg
  WHERE order_id = '2000010298710362'