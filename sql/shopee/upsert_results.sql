WITH total_price AS (
	SELECT stg_shopee.id_do_pedido AS id,
	       stg_shopee.nome_de_usuario__comprador_ AS buyer__id,
           ROUND(CAST(SUM(subtotal_do_produto) AS NUMERIC), 2) AS total_price
		FROM shopee.stg_shopee AS stg_shopee
		GROUP BY id,
		         buyer__id
), insert_results AS (
	SELECT new_id.main_id,
	        total_price.buyer__id,
	        stg_shopee.data_de_criacao_do_pedido AS date_created,
	        stg_shopee.hora_completa_do_pedido AS date_approved,
	        stg_shopee.nome_do_produto AS product,
	        stg_shopee.numero_de_referencia_sku AS sku,
	        stg_shopee.quantidade AS qt,
	        stg_shopee.preco_acordado AS price,
	        ROUND(CAST((stg_shopee.taxa_de_comissao) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) AS unit_comission_fee,
	        ROUND(CAST((stg_shopee.taxa_de_servico) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) unit_service_fee,
	        stg_shopee.taxa_de_envio_pagas_pelo_comprador AS sh_cost,
	        stg_shopee.desconto_de_frete_aproximado AS sh_discount,
	        stg_shopee.taxa_de_envio_reversa AS reverse_sh_fee,
	        stg_shopee.status_da_devolucao___reembolso AS refund_status
		FROM shopee.new_id AS new_id, shopee.stg_shopee AS stg_shopee, total_price
		WHERE new_id.id_do_pedido = stg_shopee.id_do_pedido
		AND total_price.id = stg_shopee.id_do_pedido
		AND total_price.id = new_id.id_do_pedido
		AND total_price.buyer__id = stg_shopee.nome_de_usuario__comprador_
		AND new_id.sku = stg_shopee.numero_de_referencia_sku
) INSERT INTO shopee.orders_results (
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
	refund_status
)  SELECT insert_results.main_id,
	        insert_results.buyer__id,
	        insert_results.date_created,
	        insert_results.date_approved,
	        insert_results.product,
	        insert_results.sku,
	        insert_results.qt,
	        insert_results.price,
	        insert_results.unit_comission_fee,
	        insert_results.unit_service_fee,
	        insert_results.sh_cost,
	        insert_results.sh_discount,
	        insert_results.reverse_sh_fee,
	        insert_results.refund_status
        FROM insert_results
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
                  refund_status = EXCLUDED.refund_status

/*Aux Query*/

-- WITH total_price AS (
-- 	SELECT stg_shopee.id_do_pedido AS id,
-- 	       stg_shopee.nome_de_usuario__comprador_ AS buyer__id,
--            ROUND(CAST(SUM(subtotal_do_produto) AS NUMERIC), 2) AS total_price
-- 		FROM shopee.stg_shopee AS stg_shopee
-- 		GROUP BY id,
-- 		         buyer__id
-- ), results AS (
-- 	SELECT new_id.main_id,
-- 			stg_shopee.id_do_pedido,
-- 	        total_price.buyer__id,
-- 	        stg_shopee.data_de_criacao_do_pedido AS date_created,
-- 	        stg_shopee.hora_completa_do_pedido AS date_approved,
-- 	        stg_shopee.nome_do_produto AS product,
-- 	        stg_shopee.numero_de_referencia_sku AS sku,
-- 	        stg_shopee.quantidade AS qt,
-- 	        stg_shopee.preco_acordado AS price,
-- 	        ROUND(CAST((stg_shopee.taxa_de_comissao) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) AS unit_comission_fee,
-- 	        ROUND(CAST((stg_shopee.taxa_de_servico) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) unit_service_fee,
-- 	        stg_shopee.taxa_de_envio_pagas_pelo_comprador AS sh_cost,
-- 	        stg_shopee.desconto_de_frete_aproximado AS sh_discount,
-- 	        stg_shopee.taxa_de_envio_reversa AS reverse_sh_fee,
-- 	        stg_shopee.status_da_devolucao___reembolso AS refund_status
-- 		FROM shopee.new_id AS new_id, shopee.stg_shopee AS stg_shopee, total_price
-- 		WHERE new_id.id_do_pedido = stg_shopee.id_do_pedido
-- 		AND total_price.id = stg_shopee.id_do_pedido
-- 		AND total_price.id = new_id.id_do_pedido
-- 		AND total_price.buyer__id = stg_shopee.nome_de_usuario__comprador_
-- 		AND new_id.sku = stg_shopee.numero_de_referencia_sku
-- ) SELECT * FROM results
--   WHERE main_id = '240817FD3Y8W0VCAP002VAR005'