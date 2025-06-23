def postgres_ingestion_ml(test_run, env):
    import dlt
    from dlt.destinations import postgres
    import json
    import os
    import pathlib
    from dotenv import load_dotenv

    load_dotenv()

    if test_run:
        dir = "./local/data/mercadolivre/raw/dev/sample.json"
        files = [dir]
        creds = "postgresql://airflow:airflow@localhost:5432/dev_sales_db"
    else:
        dir = f"/opt/airflow/data/mercadolivre/raw/{env}/"

        if env == 'prod':
            creds = "postgresql://airflow:airflow@pgdatabase:5432/sales_db"
        elif env == 'dev':
            creds = "postgresql://airflow:airflow@pgdatabase:5432/dev_sales_db"
        else:
            raise Exception(f"No environment named {env}")
        
        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]

    pipeline = dlt.pipeline(
        pipeline_name="mercadolivre_data",
        dataset_name="entry",
        destination=postgres(credentials=creds),
    )


    for file in files:
        if pathlib.Path(file).suffix == ".json":
            with open(file, "r", encoding="utf-8") as json_file:
                data = [json.load(json_file)]

            print(f"trying to load {file} to sales_db")
            info = pipeline.run(data, table_name="entry_mercadolivre", write_disposition="append")

            print(info)
            print(pipeline.last_trace)
            result = 1
        else:
            print(f"[WARNING] - file {file} does not have .json extension and could not be loaded.")
            result = -1
            
    return result
