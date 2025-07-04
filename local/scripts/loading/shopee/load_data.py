def postgres_ingestion_shopee(test_run: bool, env: str) -> int:
    from config.config import PATHS
    
    import pandas as pd
    from sqlalchemy import create_engine
    import os
    import pathlib

    if test_run:
        dir = PATHS['load_data_shopee']['test']['dir']
        files = [dir]
        db_config = 'postgresql://airflow:airflow@localhost:5432/sales_db'
    else:
        if env == 'prod':
            dir = PATHS['load_data_shopee']['prod']['dir']
            db_config = f'postgresql://airflow:airflow@pgdatabase/sales_db'
        elif env == 'dev':
            dir = PATHS['load_data_shopee']['dev']['dir']
            db_config = f'postgresql://airflow:airflow@pgdatabase/dev_sales_db'

        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]

    for file in files:
        if pathlib.Path(file).suffix == ".xlsx":
            df = pd.read_excel(file, engine = 'openpyxl')

            df.columns = [clean_name(column) for column in df.columns]

            df.data_prevista_de_envio = pd.to_datetime(df.data_prevista_de_envio, utc = True)
            df.tempo_de_envio = pd.to_datetime(df.tempo_de_envio, utc = True)
            df.data_de_criacao_do_pedido = pd.to_datetime(df.data_de_criacao_do_pedido, utc = True)
            df.hora_completa_do_pedido = pd.to_datetime(df.hora_completa_do_pedido, utc = True)
            df.hora_do_pagamento_do_pedido = pd.to_datetime(df.hora_do_pagamento_do_pedido, utc = True)

            df["observacao_do_comprador"] = df["observacao_do_comprador"].astype(str)

            df["load_timestamp"] = pd.Timestamp.now()

            engine = create_engine(db_config)

            try:
                print(f"Loading file {file} to {env} sales_db")
                df.to_sql(name="entry_shopee", schema="entry", con=engine, if_exists='append', index=False)
                print(f"Data in {file} successfully loaded.")
            except Exception as e:
                print(f"An exception has occured on file {file}.")
                print("--------------------------------------------------")
                print(e)
                print("--------------------------------------------------")
        else:
            print(f"[WARNING] - file {file} does not have .xlsx extension and could not be loaded.")

    print("All data successfully loaded!")
    return 1

def clean_name(name: str) -> str:
    from unidecode import unidecode
    import re

    name = unidecode(name)
    name = name.lower()
    name = re.sub(r"[^\w]", "_", name)
    return name
