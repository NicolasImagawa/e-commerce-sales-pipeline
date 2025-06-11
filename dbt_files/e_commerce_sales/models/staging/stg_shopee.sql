{{
    config(
        materialized='incremental',
        unique_key='load_id',
        incremental_strategy='merge'
    )
}}

WITH max_timestamp AS (SELECT CURRENT_TIMESTAMP AS load_timestamp)
, new_data AS (
SELECT  CONCAT(id_do_pedido, numero_de_referencia_sku) AS load_id,
        id_do_pedido,
        status_do_pedido,
        status_da_devolucao___reembolso,
        numero_de_rastreamento,
        opcao_de_envio,
        metodo_de_envio,
        data_prevista_de_envio,
        tempo_de_envio,
        data_de_criacao_do_pedido,
        hora_do_pagamento_do_pedido,
        no_de_referencia_do_sku_principal,
        nome_do_produto,
        numero_de_referencia_sku,
        nome_da_variacao,
        preco_original,
        preco_acordado,
        quantidade,
        returned_quantity,
        subtotal_do_produto,
        desconto_do_vendedor,
        desconto_do_vendedor_1,
        reembolso_shopee,
        peso_total_sku,
        numero_de_produtos_pedidos,
        peso_total_do_pedido,
        codigo_do_cupom,
        cupom_do_vendedor,
        seller_absorbed_coin_cashback,
        cupom_shopee,
        indicador_da_leve_mais_por_menos,
        desconto_shopee_da_leve_mais_por_menos,
        desconto_da_leve_mais_por_menos_do_vendedor,
        compensar_moedas_shopee,
        total_descontado_cartao_de_credito,
        valor_total,
        taxa_de_envio_pagas_pelo_comprador,
        desconto_de_frete_aproximado,
        taxa_de_envio_reversa,
        taxa_de_transacao,
        taxa_de_comissao,
        taxa_de_servico,
        total_global,
        valor_estimado_do_frete,
        nome_de_usuario__comprador_,
        nome_do_destinatario,
        telefone,
        cpf_do_comprador,
        endereco_de_entrega,
        cidade,
        bairro,
        cidade_1,
        uf,
        pais,
        cep,
        observacao_do_comprador,
        hora_completa_do_pedido,
        nota,
        load_timestamp
    FROM {{ source('entry_shopee', 'entry_shopee') }}
    {% if is_incremental() %}
        WHERE load_timestamp > (SELECT MAX(load_timestamp) from {{this}})
    {% endif %}
), update_data AS (
    SELECT * FROM new_data
    {% if is_incremental() %}
        WHERE load_id IN (SELECT load_id from {{this}})
    {% endif %}
), insert_data AS (
    SELECT * FROM new_data
    {% if is_incremental() %}
        WHERE load_id NOT IN (SELECT load_id from update_data)
    {% endif %}
)
SELECT * FROM update_data
UNION
SELECT * FROM insert_data