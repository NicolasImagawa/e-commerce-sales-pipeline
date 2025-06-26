def postgres_ingestion_sh_costs(test_run: bool, env: str) -> None:
    from config.config import PATHS
    
    import dlt
    from dlt.destinations import postgres
    import os
    import json
    import pathlib

    if test_run:
        creds = "postgresql://airflow:airflow@localhost:5432/sales_db"
        file = os.environ["SHIPPING_SAMPLE"]
    else:
        if env == 'prod':
            db = 'sales_db'
        elif env == 'dev':
            db = 'dev_sales_db'

        creds = f"postgresql://airflow:airflow@pgdatabase:5432/{db}"
        
    pipeline = dlt.pipeline(
        pipeline_name="mercadolivre_shipping",
        dataset_name="entry",
        destination=postgres(credentials=creds),
    )

    if test_run:
        data = [file]
        try:
            print(f"trying to load to entry schema")
            info = pipeline.run(data, table_name="entry_mercadolivre_sh", write_disposition="append")
            print(info)
            print(pipeline.last_trace)
            return 1
        except Exception as e:
            print(f"Unexpected error: {e}")    
        
    else:
        if env == 'prod':
            path = PATHS['load_shipping_cost']['prod']['path']
        else:
            path = PATHS['load_shipping_cost']['dev']['path']

        filelist= os.listdir(path)
        paths = [f"{path}{file}" for file in filelist]
        

        for path in paths:
            if pathlib.Path(path).suffix == ".json":
                with open(path, "r", encoding="utf-8") as json_file:
                    data = json.load(json_file)

                if len(data["destination"]["shipping_address"]["types"]) == 0:
                    data["destination"]["shipping_address"]["types"] = ["N/A"]

                if len(data["tags"]) == 0:
                    data["tags"] = ["N/A"]

                    with open(path, "w", encoding="utf-8") as editted_file:
                        json.dump(data, editted_file)


        for path in paths:
            if pathlib.Path(path).suffix == ".json":
                with open(path, "r", encoding="utf-8") as json_file:
                    data = [json.load(json_file)]

                print(f"trying to load {path} to entry schema")
                info = pipeline.run(data, table_name="entry_mercadolivre_sh", write_disposition="append")

                print(info)
                print(pipeline.last_trace)
    