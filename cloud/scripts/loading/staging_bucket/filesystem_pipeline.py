import boto3

import pandas as pd
import pathlib

INPUT_BUCKET_URL = "e-commerce-sales-bucket"
input_prefix = "data/shopee/clean/dev/"

OUTPUT_BUCKET_URL = "e-commerce-sales-staging"
output_key_prefix = "data/shopee/dev/"

timestamp_cols = ["data_prevista_de_envio", "tempo_de_envio", "data_de_criacao_do_pedido", "hora_completa_do_pedido", "hora_do_pagamento_do_pedido"]
str_cols = ["cupom_do_vendedor", "cupom_shopee", "cpf_do_comprador", "cep", "cidade", "observacao_do_comprador", "nota"]

def convert_and_load() -> None:
    s3 = boto3.client('s3')
    print("Trying to get files from S3")

    objects = s3.list_objects_v2(Bucket=INPUT_BUCKET_URL, Prefix = input_prefix)

    if 'Contents' in objects:
        for obj in objects['Contents']:
            key = obj['Key']
            print(f"Downloading {key}")

            try:
                response = s3.get_object(Bucket=INPUT_BUCKET_URL, Key=key)
                print(key.split("/"))
                
                filename = key.split("/")[-1]
                filename = filename[:-4]
                print(filename)

                print(f"File {filename} successfully accessed.")

                df = pd.read_csv(response['Body'])

                print("Creating load_id") #This is a key to be used inside the warehouse.

                df["load_id"] = df["id_do_pedido"] + df["numero_de_referencia_sku"]

                print("Converting timestamps...")

                df.data_prevista_de_envio = pd.to_datetime(df.data_prevista_de_envio, utc = True)
                df.tempo_de_envio = pd.to_datetime(df.tempo_de_envio, utc = True)
                df.data_de_criacao_do_pedido = pd.to_datetime(df.data_de_criacao_do_pedido, utc = True)
                df.hora_completa_do_pedido = pd.to_datetime(df.hora_completa_do_pedido, utc = True)
                df.hora_do_pagamento_do_pedido = pd.to_datetime(df.hora_do_pagamento_do_pedido, utc = True)

                for col in timestamp_cols:
                    df[col] = df[col].dt.tz_localize(None)
                    df[col] = df[col].astype('datetime64[us]')

                for col in str_cols:
                    df[col] = df[col].astype('str')


                df["load_timestamp"] = pd.Timestamp.now()
                df.load_timestamp = pd.to_datetime(df.load_timestamp, utc = True)
                df["load_timestamp"] = df["load_timestamp"].dt.tz_localize(None)
                df["load_timestamp"] = df["load_timestamp"].dt.floor('S')

                print(f"Transformed file {filename} into parquet.")
                filepath = f'{filename}.parquet'

                df.to_parquet(filepath)
                
                print("Trying to load files to staging bucket.")

                output_key = f"{output_key_prefix}{filepath}"
                s3.upload_file(filepath, OUTPUT_BUCKET_URL, output_key)
                print("Files loaded successfully")

            except Exception as e:
                print(f"Error while trying to transform the data: {e}")
                raise e
                return
convert_and_load()

