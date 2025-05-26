CREATE TABLE IF NOT EXISTS mercadolivre.orders_results (
    main_id BIGINT UNIQUE NOT NULL,
	buyer__id BIGINT,
	order_id BIGINT NOT NULL,
	product VARCHAR(200),
	sku VARCHAR(30),
	date_approved TIMESTAMP WITH TIME ZONE,
	payment_method_id VARCHAR(20),
	qt INT,
    CHECK (qt > 0),
	total_paid_amount NUMERIC(7,2),
	transaction_amount NUMERIC(7,2),
	price NUMERIC(7,2),
    CHECK (price > 0),
	sh_cost NUMERIC(4,2),
	fee NUMERIC(6,2),
    CHECK (fee > 0)
)


/*Alternative and testing*/
CREATE TABLE IF NOT EXISTS results AS (
WITH buyers AS (
		SELECT ml.buyer__id,
			   ml._dlt_id
		FROM mercadolivre.mercadolivre AS ml
	), product_sku_qt_price_fee AS (
		SELECT orders.item__title AS product,
			   orders.item__seller_sku AS sku,
			   orders.quantity AS qt,
			   orders.unit_price AS price,
			   orders.sale_fee AS fee,
			   orders._dlt_parent_id AS _dlt_parent_id
			   FROM mercadolivre.mercadolivre__order_items AS orders
	), results AS (
		SELECT payments.id AS main_id,
			   buyers.buyer__id,
			   payments.order_id,
			   payments.reason AS product,
			   product_sku_qt_price_fee.sku,
			   payments.date_approved,
			   payments.payment_method_id,
			   product_sku_qt_price_fee.qt,
			   payments.total_paid_amount,
			   payments.transaction_amount,
			   product_sku_qt_price_fee.price,
			   COALESCE(payments.shipping_cost__v_double, 0) AS sh_cost,
			   product_sku_qt_price_fee.fee
		FROM mercadolivre.mercadolivre__payments AS payments
			INNER JOIN product_sku_qt_price_fee
			ON product_sku_qt_price_fee.product = payments.reason
			AND payments._dlt_parent_id = product_sku_qt_price_fee._dlt_parent_id
			INNER JOIN buyers
			ON buyers._dlt_id = payments._dlt_parent_id
		WHERE payments.status = 'approved'
	) 
	SELECT results.main_id,
		   results.buyer__id,
		   results.order_id,
		   results.product,
		   results.sku,
		   results.date_approved,
		   results.payment_method_id,
		   results.qt,
		   results.total_paid_amount,
		   results.transaction_amount,
		   results.price,
		   results.sh_cost,
		   results.fee
	FROM results
)