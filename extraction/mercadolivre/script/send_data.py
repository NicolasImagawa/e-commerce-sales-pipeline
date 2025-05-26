def postgres_ingestion_ml(test_run):
    import dlt
    from dlt.destinations import postgres
    import json
    import os
    import pathlib

    if test_run:
        dir = "./extraction/mercadolivre/data/raw/sample.json"
        files = [dir]
        creds = "postgresql://airflow:airflow@localhost:5432/sales_db"
    else:
        dir = "./extraction/mercadolivre/data/raw/"
        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]
        creds = "postgresql://airflow:airflow@pgdatabase/sales_db"


    pipeline = dlt.pipeline(
        pipeline_name="mercadolivre_data",
        dataset_name="stg",
        destination=postgres(credentials=creds),
    )
    
    if test_run:
        dir = "./extraction/mercadolivre/data/raw/sample.json"
        files = [dir]
    else:
        dir = "./extraction/mercadolivre/data/raw/"
        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]


    for file in files:

        if pathlib.Path(file).suffix == ".json":
            with open(file, "r", encoding="utf-8") as json_file:
                data = [json.load(json_file)]

            print(f"trying to load {file} to sales_db")
            info = pipeline.run(data, table_name="stg_mercadolivre", write_disposition="append")

            print(info)
            print(pipeline.last_trace)
            result = 1
        else:
            print(f"[WARNING] - file {file} does not have .json extension and could not be loaded.")
            result = -1
            
    return result
