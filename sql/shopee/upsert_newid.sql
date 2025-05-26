WITH transform_id AS 
(SELECT id_do_pedido, 
        CONCAT(id_do_pedido, numero_de_referencia_sku) AS main_id
	FROM shopee.stg_shopee)
INSERT INTO shopee.new_id 
(
	id_do_pedido,
	main_id
) SELECT id_do_pedido, 
		  main_id
  FROM transform_id
  ON CONFLICT (main_id)
  DO UPDATE SET id_do_pedido = EXCLUDED.id_do_pedido,
  				main_id = EXCLUDED.main_id