{{
    config(
        materialized='incremental',
        unique_key='main_id',
        incremental_strategy='merge'
    )
}}

WITH id_buyer_sku_price AS (
    SELECT stg_shopee.load_id AS id,
           stg_shopee.nome_de_usuario__comprador_  AS buyer__id,
           stg_shopee.hora_do_pagamento_do_pedido AS date_approved,
           stg_shopee.numero_de_referencia_sku AS sku,
           stg_shopee.load_timestamp AS load_timestamp,
           COALESCE(ROUND(CAST(SUM(stg_shopee.subtotal_do_produto) AS NUMERIC), 2), 0) AS total_price
        FROM {{ ref("stg_shopee") }} AS stg_shopee

        {% if is_incremental() %}

            WHERE stg_shopee.load_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }}) /*the "this" keyword compares to shopee_orders_results table*/

        {% endif %}

        GROUP BY stg_shopee.load_id,
                 stg_shopee.nome_de_usuario__comprador_,
                 stg_shopee.hora_do_pagamento_do_pedido,
                 stg_shopee.numero_de_referencia_sku,
                 stg_shopee.load_timestamp
), id_buyer_sku_price_component AS (
    SELECT id_buyer_sku_price.id,
           id_buyer_sku_price.buyer__id,
           id_buyer_sku_price.date_approved,
           id_buyer_sku_price.sku,
           id_buyer_sku_price.total_price,
           kit_components.component_sku,
           id_buyer_sku_price.load_timestamp
        FROM id_buyer_sku_price
        LEFT JOIN {{ source("supplies", "kit_components") }} AS kit_components
            ON id_buyer_sku_price.sku = kit_components.sku
        
        {% if is_incremental() %}

            WHERE id_buyer_sku_price.load_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }}) /*the "this" keyword compares to shopee_orders_results table*/

        {% endif %}

), total_price AS (
	SELECT id_buyer_sku_price_component.id,
	       id_buyer_sku_price_component.buyer__id,
           id_buyer_sku_price_component.date_approved,
           id_buyer_sku_price_component.sku,
           id_buyer_sku_price_component.total_price,
           COALESCE(SUM(costs.cost), 0) AS total_prod_cost,
           id_buyer_sku_price_component.load_timestamp
		FROM id_buyer_sku_price_component
        LEFT JOIN {{ source("supplies", "product_sku_cost") }} AS costs
            ON id_buyer_sku_price_component.component_sku = costs.sku
            AND (id_buyer_sku_price_component.date_approved <= costs.end_date OR costs.end_date IS NULL)
            AND id_buyer_sku_price_component.date_approved >= costs.begin_date

        {% if is_incremental() %}

            WHERE id_buyer_sku_price_component.load_timestamp > (SELECT MAX(ld_timestamp) FROM {{ this }}) /*the "this" keyword compares to shopee_orders_results table*/

        {% endif %}

		GROUP BY id_buyer_sku_price_component.id,
                 id_buyer_sku_price_component.buyer__id,
                 id_buyer_sku_price_component.date_approved,
                 id_buyer_sku_price_component.sku,
                 id_buyer_sku_price_component.total_price,
                 id_buyer_sku_price_component.load_timestamp
), new_data AS (
	SELECT  stg_shopee.load_id AS main_id,
	        total_price.buyer__id,
            CONCAT('SH_', {{ dbt_utils.generate_surrogate_key(['stg_shopee.load_id', 'stg_shopee.data_de_criacao_do_pedido']) }}) AS date_id,
            CONCAT('SH_', stg_shopee.numero_de_referencia_sku) AS product_id,
	        stg_shopee.quantidade AS qt,
	        stg_shopee.preco_acordado AS price,
            CASE WHEN total_price.total_price = 0
	            THEN 0
                ELSE ROUND(CAST((stg_shopee.taxa_de_comissao) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) 
            END AS unit_comission_fee,
            CASE WHEN total_price.total_price = 0
                THEN 0
	            ELSE ROUND(CAST((stg_shopee.taxa_de_servico) * (stg_shopee.preco_acordado / total_price.total_price) AS NUMERIC), 2) 
                END AS unit_service_fee,
	        stg_shopee.taxa_de_envio_pagas_pelo_comprador AS sh_cost,
	        stg_shopee.desconto_de_frete_aproximado AS sh_discount,
	        stg_shopee.taxa_de_envio_reversa AS reverse_sh_fee,
            total_price.total_prod_cost,
            total_price.load_timestamp AS ld_timestamp
            
		FROM {{ ref("stg_shopee") }} AS stg_shopee, total_price
		WHERE total_price.id = stg_shopee.load_id
		AND total_price.buyer__id = stg_shopee.nome_de_usuario__comprador_
        AND total_price.sku = stg_shopee.numero_de_referencia_sku
        AND stg_shopee.status_da_devolucao___reembolso IS NULL
        {% if is_incremental() %}

            AND stg_shopee.load_id IN (SELECT main_id FROM {{ this }})

        {% endif %}
), update_results AS (
	SELECT  new_data.main_id,
	        new_data.buyer__id,
            new_data.date_id,
            new_data.product_id,
	        new_data.qt,
	        new_data.price,
            new_data.unit_comission_fee,
            new_data.unit_service_fee,
	        new_data.sh_cost,
	        new_data.sh_discount,
	        new_data.reverse_sh_fee,
            new_data.total_prod_cost,
            ROUND(CAST((new_data.price - new_data.unit_comission_fee - new_data.unit_service_fee - new_data.total_prod_cost) - new_data.reverse_sh_fee AS NUMERIC), 2) AS profit,
            new_data.ld_timestamp
		FROM new_data
        {% if is_incremental() %}

            WHERE new_data.main_id IN (SELECT main_id FROM {{ this }})

        {% endif %}
),  insert_results AS (
	SELECT  new_data.main_id,
	        new_data.buyer__id,
            new_data.date_id,
            new_data.product_id,
	        new_data.qt,
	        new_data.price,
            new_data.unit_comission_fee,
            new_data.unit_service_fee,
	        new_data.sh_cost,
	        new_data.sh_discount,
	        new_data.reverse_sh_fee,
            new_data.total_prod_cost,
            ROUND(CAST((new_data.price - new_data.unit_comission_fee - new_data.unit_service_fee - new_data.total_prod_cost) - new_data.reverse_sh_fee AS NUMERIC), 2) AS profit,
            new_data.ld_timestamp
		FROM new_data
        WHERE new_data.main_id NOT IN (SELECT main_id FROM update_results)
)
SELECT  main_id,
        buyer__id,
        date_id,
        product_id,
        qt,
        price,
        unit_comission_fee,
        unit_service_fee,
        sh_cost,
        sh_discount,
        reverse_sh_fee,
        total_prod_cost,
        profit,
        ld_timestamp
    FROM update_results
    UNION
SELECT  main_id,
        buyer__id,
        date_id,
        product_id,
        qt,
        price,
        unit_comission_fee,
        unit_service_fee,
        sh_cost,
        sh_discount,
        reverse_sh_fee,
        total_prod_cost,
        profit,
        ld_timestamp
    FROM insert_results
