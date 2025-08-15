import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

from pyspark.sql.functions import concat, col
from pyspark.sql.functions import date_format
from pyspark.sql.functions import current_timestamp

from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

spark_context = SparkContext.getOrCreate()
glueContext = GlueContext(spark_context)
spark = glueContext.spark_session

timestamp_cols = ["data_prevista_de_envio", "tempo_de_envio", "data_de_criacao_do_pedido", "hora_completa_do_pedido", "hora_do_pagamento_do_pedido"]
str_cols = ["cupom_do_vendedor", "cupom_shopee", "cpf_do_comprador", "cep", "cidade", "observacao_do_comprador", "nota"]

INPUT_FILES = "s3://e-commerce-sales-bucket/data/shopee/clean/dev/"
OUTPUT_PATH = "s3://e-commerce-sales-staging/spark_test/"

df = spark.read.csv(INPUT_FILES, header=True, inferSchema=True)

df = df.withColumn(
        "load_id",
        concat(
            col("id_do_pedido").cast("string"),
            col("numero_de_referencia_sku").cast("string")
        )
    )
    
df.show(10)
print(df.dtypes)

for col in timestamp_cols:
    df = df.withColumn(
            col,
            date_format(col(col), "YYYY/mm/dd HH:MM:SS")
        )

for col in str_cols:
    df = df.withColumn(
            col,
            col(col).cast("string")
        )

df = df.withColumn(
        "load_timestamp",
        current_timestamp()
    )

df = df.withColumn(
        "load_timestamp",
        date_format(col("load_timestamp"), "YYYY/mm/dd HH:MM:SS")
    )
    
df.write.parquet(OUTPUT_PATH)

df.show(10)

job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()