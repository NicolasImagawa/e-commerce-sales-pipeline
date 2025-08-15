import redshift_connector

conn = redshift_connector.connect(
    host='e-commerce-sales.XXXXXXXXXXXX.YOUR-REGION.redshift-serverless.amazonaws.com',
    database='dev',
    user='User',
    password='Password',
)

conn.autocommit = True
cursor = conn.cursor()

def table_exists(cursor, schema_name, table_name):
    """Check if a table exists in the specified schema."""
    cursor.execute(f"""
        SELECT 1 
        FROM svv_external_tables 
        WHERE schemaname = '{schema_name}' 
        AND tablename = '{table_name}'
    """)
    return cursor.fetchone() is not None

print("Creating schema...")
cursor.execute("""
    CREATE EXTERNAL SCHEMA IF NOT EXISTS spectrum_schema
    FROM DATA CATALOG
    DATABASE 'spectrum_db'
    IAM_ROLE 'arn:aws:iam::XXXXXXXXXXXX:role/redshift-IAM'
    CREATE EXTERNAL DATABASE IF NOT EXISTS;
""")
print("Schema created or already exists.")

# Kit Components Table
table_name = "kit_components"
if not table_exists(cursor, "spectrum_schema", table_name):
    print(f"Creating external table for {table_name}...")
    cursor.execute(f"""
        CREATE EXTERNAL TABLE spectrum_schema.{table_name} 
        (
            main_sku VARCHAR(15),
            product VARCHAR(200),
            sku VARCHAR(15),
            component_sku VARCHAR(15),
            component_name VARCHAR(200) 
        )
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
        STORED AS TEXTFILE
        LOCATION 's3://e-commerce-sales-bucket/data/supplies/clean/spectrum_kit_prod/'
        TABLE PROPERTIES ('skip.header.line.count'='1');
    """)
    print(f"Table {table_name} created successfully.")
else:
    print(f"Table {table_name} already exists.")

# Product SKU Cost Table
table_name = "product_sku_cost"
if not table_exists(cursor, "spectrum_schema", table_name):
    print(f"Creating external table for {table_name}...")
    cursor.execute(f"""
        CREATE EXTERNAL TABLE spectrum_schema.{table_name} 
        (
            main_sku VARCHAR(15),
            product VARCHAR(200),
            sku VARCHAR(15),
            component_name VARCHAR(200),
            begin_date TIMESTAMP,
            end_date TIMESTAMP,
            cost NUMERIC(7, 2) 
        )
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ',' 
        STORED AS TEXTFILE
        LOCATION 's3://e-commerce-sales-bucket/data/supplies/clean/spectrum_costs_prod/'
        TABLE PROPERTIES ('skip.header.line.count'='1');
    """)
    print(f"Table {table_name} created successfully.")
else:
    print(f"Table {table_name} already exists.")

# Shopee Staging Table
table_name = "stg_shopee"
if not table_exists(cursor, "spectrum_schema", table_name):
    print(f"Creating external table for {table_name}...")
    cursor.execute(f"""
        CREATE EXTERNAL TABLE spectrum_schema.{table_name} (
            load_id VARCHAR(100),
            id_do_pedido VARCHAR(30),
            status_do_pedido VARCHAR(70),
            status_da_devolucao___reembolso VARCHAR(70),
            numero_de_rastreamento VARCHAR(70),
            opcao_de_envio VARCHAR(70),
            metodo_de_envio VARCHAR (70),
            data_prevista_de_envio TIMESTAMP,
            tempo_de_envio TIMESTAMP,
            data_de_criacao_do_pedido TIMESTAMP,
            hora_do_pagamento_do_pedido TIMESTAMP,
            no_de_referencia_do_sku_principal VARCHAR(40),
            nome_do_produto VARCHAR(150),
            numero_de_referencia_sku VARCHAR(30),
            nome_da_variacao VARCHAR(30),
            preco_original FLOAT8,
            preco_acordado FLOAT8,
            quantidade BIGINT,
            returned_quantity BIGINT,
            subtotal_do_produto FLOAT8,
            desconto_do_vendedor FLOAT8,
            desconto_do_vendedor_1 FLOAT8,
            reembolso_shopee FLOAT8,
            peso_total_sku FLOAT8,
            numero_de_produtos_pedidos BIGINT,
            peso_total_do_pedido FLOAT8,
            codigo_do_cupom VARCHAR(30),
            cupom_do_vendedor VARCHAR(30),
            seller_absorbed_coin_cashback FLOAT8,
            cupom_shopee VARCHAR(30),
            indicador_da_leve_mais_por_menos VARCHAR(30),
            desconto_shopee_da_leve_mais_por_menos FLOAT8,
            desconto_da_leve_mais_por_menos_do_vendedor FLOAT8,
            compensar_moedas_shopee BIGINT,
            total_descontado_cartao_de_credito FLOAT8,
            valor_total FLOAT8,
            taxa_de_envio_pagas_pelo_comprador FLOAT8,
            desconto_de_frete_aproximado FLOAT8,
            taxa_de_envio_reversa FLOAT8,
            taxa_de_transacao FLOAT8,
            taxa_de_comissao FLOAT8,
            taxa_de_servico FLOAT8,
            total_global FLOAT8,
            valor_estimado_do_frete FLOAT8,
            nome_de_usuario__comprador_ VARCHAR(30),
            nome_do_destinatario VARCHAR(60),
            telefone VARCHAR(15),
            cpf_do_comprador VARCHAR(14),
            endereco_de_entrega VARCHAR(100),
            cidade VARCHAR(100),
            bairro VARCHAR(100),
            cidade_1 VARCHAR(100),
            uf VARCHAR(2),
            pais VARCHAR(6),
            cep VARCHAR(9),
            observacao_do_comprador VARCHAR(100),
            hora_completa_do_pedido TIMESTAMP,
            nota VARCHAR(100),
            load_timestamp TIMESTAMP
        )
        STORED AS PARQUET
        LOCATION 's3://e-commerce-sales-staging/data/shopee/dev/'
    """)
    print(f"Table {table_name} created successfully.")
else:
    print(f"Table {table_name} already exists.")

conn.close()