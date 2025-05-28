from pathlib import Path
import sys
import psycopg2
from psycopg2 import sql

sys.path.insert(0, str(Path(__file__).parent.parent))

from dbt_files.install_deps import install_dependencies
from dbt_files.prepare_testing import run_empty_shopee_tables
from dbt_files.prepare_testing import run_shopee_fact_table

def test_transform():
    print("\n=================== test_transformation.py started ===================")
    conn = psycopg2.connect(database = "postgres", user = "airflow", host= 'localhost', password = "airflow", port = 5432) #uses maintenance db to create the infrastructure
    cursor = conn.cursor()
    conn.autocommit = True
    
    cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier("sales_db")))

    conn = psycopg2.connect(database = "sales_db", user = "airflow", host= 'localhost', password = "airflow", port = 5432)
    cursor.execute(sql.SQL("CREATE SCHEMA {}").format(sql.Identifier("stg")))
    cursor.execute(sql.SQL("""CREATE TABLE IF NOT EXISTS stg.{} (
                                id_do_pedido text COLLATE pg_catalog."default",
                                status_do_pedido text COLLATE pg_catalog."default",
                                status_da_devolucao___reembolso text COLLATE pg_catalog."default",
                                numero_de_rastreamento text COLLATE pg_catalog."default",
                                opcao_de_envio text COLLATE pg_catalog."default",
                                metodo_de_envio text COLLATE pg_catalog."default",
                                data_prevista_de_envio timestamp with time zone,
                                tempo_de_envio timestamp with time zone,
                                data_de_criacao_do_pedido timestamp with time zone,
                                hora_do_pagamento_do_pedido timestamp with time zone,
                                no_de_referencia_do_sku_principal text COLLATE pg_catalog."default",
                                nome_do_produto text COLLATE pg_catalog."default",
                                numero_de_referencia_sku text COLLATE pg_catalog."default",
                                nome_da_variacao text COLLATE pg_catalog."default",
                                preco_original double precision,
                                preco_acordado double precision,
                                quantidade bigint,
                                returned_quantity bigint,
                                subtotal_do_produto double precision,
                                desconto_do_vendedor double precision,
                                desconto_do_vendedor_1 double precision,
                                reembolso_shopee double precision,
                                peso_total_sku double precision,
                                numero_de_produtos_pedidos bigint,
                                peso_total_do_pedido double precision,
                                codigo_do_cupom text COLLATE pg_catalog."default",
                                cupom_do_vendedor double precision,
                                seller_absorbed_coin_cashback double precision,
                                cupom_shopee double precision,
                                indicador_da_leve_mais_por_menos text COLLATE pg_catalog."default",
                                desconto_shopee_da_leve_mais_por_menos double precision,
                                desconto_da_leve_mais_por_menos_do_vendedor double precision,
                                compensar_moedas_shopee bigint,
                                total_descontado_cartao_de_credito double precision,
                                valor_total double precision,
                                taxa_de_envio_pagas_pelo_comprador double precision,
                                desconto_de_frete_aproximado double precision,
                                taxa_de_envio_reversa double precision,
                                taxa_de_transacao double precision,
                                taxa_de_comissao double precision,
                                taxa_de_servico double precision,
                                total_global double precision,
                                valor_estimado_do_frete double precision,
                                nome_de_usuario__comprador_ text COLLATE pg_catalog."default",
                                nome_do_destinatario text COLLATE pg_catalog."default",
                                telefone text COLLATE pg_catalog."default",
                                cpf_do_comprador double precision,
                                endereco_de_entrega text COLLATE pg_catalog."default",
                                cidade double precision,
                                bairro text COLLATE pg_catalog."default",
                                cidade_1 text COLLATE pg_catalog."default",
                                uf text COLLATE pg_catalog."default",
                                pais text COLLATE pg_catalog."default",
                                cep bigint,
                                observacao_do_comprador text COLLATE pg_catalog."default",
                                hora_completa_do_pedido timestamp with time zone,
                                nota double precision,
                                load_timestamp timestamp without time zone
                            )
                           """).format(sql.Identifier("stg_shopee")))
    cursor.execute("""
        INSERT INTO stg.stg_shopee (
            id_do_pedido, numero_de_referencia_sku, subtotal_do_produto,
            taxa_de_comissao, taxa_de_servico, preco_acordado, load_timestamp
        ) VALUES (
            '1', 'ABC001VAR001', 10.99, 1, 1, 10.99, '2025-05-20 17:16:13.338174'
        )
    """)

    cursor.execute("""
        SELECT * FROM stg.stg_shopee
    """)

    # Print column headers first
    column_names = [desc[0] for desc in cursor.description]
    print("|".join(column_names))

    print("\n******* installing dependencies *******")
    install_dependencies(test_run = True)
    print("\n******* running empty parent tables *******")
    run_empty_shopee_tables(test_run = True)
    print("\n******* testing shopee fact table *******")
    test_results = run_shopee_fact_table(test_run = True)

    cursor.execute(sql.SQL("DROP DATABASE {}").format(sql.Identifier("sales_db")))
    print("=================== test_transformation.py finished ===================")

    assert test_results == True
