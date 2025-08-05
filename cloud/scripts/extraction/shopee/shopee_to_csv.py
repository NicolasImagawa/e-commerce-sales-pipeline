def spreadsheet_to_csv(test_run, env):
    import pandas as pd
    import os
    import pathlib

    if test_run:
        dir = "./extraction/shopee/data/sample/sample.xlsx"
        files = [dir]

    else:
        if env == 'prod':
            dir = "/path/to/xlsx/files/cloud/data/shopee/raw/prod/"
            output_dir = pathlib.Path("/path/to/csv/files/cloud/data/shopee/clean/prod/")
        elif env == 'dev':
            dir = "/path/to/xlsx/files/cloud/data/shopee/raw/dev/"
            output_dir = pathlib.Path("/path/to/csv/files/cloud/data/shopee/clean/dev/")

        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]

    for file in files:
        if pathlib.Path(file).suffix == ".xlsx":
            df = pd.read_excel(file, engine = 'openpyxl')

            df.columns = [clean_name(column) for column in df.columns]

            df.data_prevista_de_envio = pd.to_datetime(df.data_prevista_de_envio, utc = True)
            df.tempo_de_envio = pd.to_datetime(df.tempo_de_envio, utc = True)
            df["preco_original"] = pd.to_numeric(df["preco_original"], errors="coerce")
            df.data_de_criacao_do_pedido = pd.to_datetime(df.data_de_criacao_do_pedido, utc = True)
            df.hora_completa_do_pedido = pd.to_datetime(df.hora_completa_do_pedido, utc = True)
            df.hora_do_pagamento_do_pedido = pd.to_datetime(df.hora_do_pagamento_do_pedido, utc = True)

            df["observacao_do_comprador"] = df["observacao_do_comprador"].astype(str)

            df["load_timestamp"] = pd.Timestamp.now()

            try:
                print(f"Converting file {file} with .csv")
                output_dir.mkdir(parents=True, exist_ok=True)
                df.to_csv(f"{output_dir}/{pathlib.Path(file).stem}.csv", header=True, encoding="utf-8", index=False)
                print(f"Data in {file} successfully converted.")
            except Exception as e:
                print(f"An exception has occured on file {file}.")
                print("--------------------------------------------------")
                print(e)
                print("--------------------------------------------------")
        else:
            print(f"[WARNING] - file {file} does not have .xlsx extension and could not be loaded.")

    print("All data successfully loaded!")
    return 1

def clean_name(name):
    from unidecode import unidecode
    import re

    name = unidecode(name)
    name = name.lower()
    name = re.sub(r"[^\w]", "_", name)
    return name

# spreadsheet_to_csv(test_run = False, env = 'prod')
spreadsheet_to_csv(test_run = False, env = 'dev')