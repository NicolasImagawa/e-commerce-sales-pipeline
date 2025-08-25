import pyspark
from pyspark.sql import SparkSession
from pyspark.sql import types
from pyspark.sql import functions as F

import pandas as pd

input_file = 'test.csv'

pandas_df = pd.read_csv(input_file, nrows = 10)

pandas_df.dropna(subset=['nome_da_variacao', 'no_de_referencia_do_sku_principal'], inplace=True)

spark = SparkSession.builder \
                    .master("local[*]") \
                    .appName("LocalAWSTesting") \
                    .getOrCreate()

spark_schema = spark.createDataFrame(pandas_df.to_dict('records')).schema

new_schema = types.StructType(
[
      types.StructField("id_do_pedido", types.StringType(), True)
    , types.StructField("status_do_pedido", types.StringType(), True)
    , types.StructField("status_da_devolucao___reembolso", types.DoubleType(), True)
    , types.StructField("numero_de_rastreamento", types.StringType(), True)
    , types.StructField("opcao_de_envio", types.StringType(), True)
    , types.StructField("metodo_de_envio", types.StringType(), True)
    , types.StructField("data_prevista_de_envio", types.StringType(), True)
    , types.StructField("tempo_de_envio", types.StringType(), True)
    , types.StructField("data_de_criacao_do_pedido", types.StringType(), True)
    , types.StructField("hora_do_pagamento_do_pedido", types.StringType(), True)
    , types.StructField("no_de_referencia_do_sku_principal", types.StringType(), True)
    , types.StructField("nome_do_produto", types.StringType(), True)
    , types.StructField("numero_de_referencia_sku", types.StringType(), True)
    , types.StructField("nome_da_variacao", types.StringType(), True)
    , types.StructField("preco_original", types.DoubleType(), True)
    , types.StructField("preco_acordado", types.DoubleType(), True)
    , types.StructField("quantidade", types.LongType(), True)
    , types.StructField("returned_quantity", types.LongType(), True)
    , types.StructField("subtotal_do_produto", types.DoubleType(), True)
    , types.StructField("desconto_do_vendedor", types.DoubleType(), True)
    , types.StructField("desconto_do_vendedor_1", types.DoubleType(), True)
    , types.StructField("reembolso_shopee", types.DoubleType(), True)
    , types.StructField("peso_total_sku", types.DoubleType(), True)
    , types.StructField("numero_de_produtos_pedidos", types.LongType(), True)
    , types.StructField("peso_total_do_pedido", types.DoubleType(), True)
    , types.StructField("codigo_do_cupom", types.StringType(), True)
    , types.StructField("cupom_do_vendedor", types.DoubleType(), True)
    , types.StructField("seller_absorbed_coin_cashback", types.DoubleType(), True)
    , types.StructField("cupom_shopee", types.DoubleType(), True)
    , types.StructField("indicador_da_leve_mais_por_menos", types.StringType(), True)
    , types.StructField("desconto_shopee_da_leve_mais_por_menos", types.DoubleType(), True)
    , types.StructField("desconto_da_leve_mais_por_menos_do_vendedor", types.DoubleType(), True)
    , types.StructField("compensar_moedas_shopee", types.LongType(), True)
    , types.StructField("total_descontado_cartao_de_credito", types.DoubleType(), True)
    , types.StructField("valor_total", types.DoubleType(), True)
    , types.StructField("taxa_de_envio_pagas_pelo_comprador", types.DoubleType(), True)
    , types.StructField("desconto_de_frete_aproximado", types.DoubleType(), True)
    , types.StructField("taxa_de_envio_reversa", types.DoubleType(), True)
    , types.StructField("taxa_de_transacao", types.DoubleType(), True)
    , types.StructField("taxa_de_comissao", types.DoubleType(), True)
    , types.StructField("taxa_de_servico", types.DoubleType(), True)
    , types.StructField("total_global", types.DoubleType(), True)
    , types.StructField("valor_estimado_do_frete", types.DoubleType(), True)
    , types.StructField("nome_de_usuario__comprador_", types.StringType(), True)
    , types.StructField("nome_do_destinatario", types.StringType(), True)
    , types.StructField("telefone", types.StringType(), True)
    , types.StructField("cpf_do_comprador", types. DoubleType(), True)
    , types.StructField("endereco_de_entrega", types.StringType(), True)
    , types.StructField("cidade", types.DoubleType(), True)
    , types.StructField("bairro", types.StringType(), True)
    , types.StructField("cidade_1", types.StringType(), True)
    , types.StructField("uf", types.StringType(), True)
    , types.StructField("pais", types.StringType(), True)
    , types.StructField("cep", types.LongType(), True)
    , types.StructField("observacao_do_comprador", types.DoubleType(), True)
    , types.StructField("hora_completa_do_pedido", types.StringType(), True)
    , types.StructField("nota", types.DoubleType(), True)
    , types.StructField("load_timestamp", types.StringType(), True)
]
)

timestamp_cols = ["data_prevista_de_envio", "tempo_de_envio", "data_de_criacao_do_pedido", "hora_completa_do_pedido", "hora_do_pagamento_do_pedido"]
str_cols = ["status_da_devolucao___reembolso", "cupom_do_vendedor", "cupom_shopee", "cpf_do_comprador", "cep", "cidade", "observacao_do_comprador", "nota"]

spark_df = spark.read \
                .option("header", "true") \
                .schema(new_schema) \
                .csv(input_file)

spark_df = spark_df.withColumn(
        "load_id",
        F.concat(
            F.col("id_do_pedido").cast("string"),
            F.col("numero_de_referencia_sku").cast("string")
        )
    )

for col in str_cols:
    spark_df = spark_df.withColumn(
            col,
            F.col(col).cast("string")
        )

for col in timestamp_cols:
    spark_df = spark_df.withColumn(
            col,
            F.to_timestamp(F.col(col))
        )

spark_df = spark_df.withColumn(
                   "load_timestamp", 
                    F.to_timestamp(F.col("load_timestamp"), "yyyy-MM-dd HH:mm:ss.SSSSSS")
           )

spark_df.write \
        .mode('overwrite') \
        .parquet('parquet_output')