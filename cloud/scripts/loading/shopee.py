# from config.config import PATHS
import dlt
import pathlib
import boto3
import pandas as pd

BUCKET_URL = "e-commerce-sales-bucket"
file_glob = "data/shopee/raw/dev/Order.completed.20240901_20240930.csv"

def load_csv() -> None:
    pipeline = dlt.pipeline(
        pipeline_name="load_raw_shopee",
        destination='redshift',
        dataset_name="entry",
    )

    s3 = boto3.client('s3')
    print("Trying to get files from S3")
    response = s3.get_object(Bucket=BUCKET_URL, Key=file_glob)
    print("File successfully accessed.")

    df = pd.read_csv(response['Body'])
    
    df.data_prevista_de_envio = pd.to_datetime(df.data_prevista_de_envio, utc = True)
    df.tempo_de_envio = pd.to_datetime(df.tempo_de_envio, utc = True)
    df.data_de_criacao_do_pedido = pd.to_datetime(df.data_de_criacao_do_pedido, utc = True)
    df.hora_completa_do_pedido = pd.to_datetime(df.hora_completa_do_pedido, utc = True)
    df.hora_do_pagamento_do_pedido = pd.to_datetime(df.hora_do_pagamento_do_pedido, utc = True)

    print(df.dtypes)
    
    df["load_timestamp"] = pd.Timestamp.now()
    print(df["hora_do_pagamento_do_pedido"].head(1))
    print(df["load_timestamp"].head(1))
    
    try:
        print(f"Loading file to db")
        load_info = pipeline.run(df, table_name="entry_shopee")
        print(f"Data successfully loaded.")
    except Exception as e:
        print(f"An Expection has occured: {e}")

if __name__ == "__main__":
    load_csv()
