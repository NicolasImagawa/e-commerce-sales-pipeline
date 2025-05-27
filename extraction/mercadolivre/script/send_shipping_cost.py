def postgres_ingestion_sh_costs(test_run):
    import dlt
    from dlt.destinations import postgres
    import os
    import json
    
    if test_run:
        creds = "postgresql://airflow:airflow@localhost:5432/sales_db"
        file = os.environ["SHIPPING_SAMPLE"]
    else:
        creds = "postgresql://airflow:airflow@pgdatabase:5432/sales_db"

    # Define a dlt pipeline with automatic normalization
    pipeline = dlt.pipeline(
        pipeline_name="mercadolivre_shipping",
        dataset_name="stg",
        destination=postgres(credentials=creds),
    )

    if test_run:
        data = [file]
        try:
            print(f"trying to load test file to stg schema")
            info = pipeline.run(data, table_name="stg_mercadolivre_sh", write_disposition="append")
            print(info)
            print(pipeline.last_trace)
            return 1
        except Exception as e:
            print(f"Unexpected error: {e}")    
        
    else:
        path = "./extraction/mercadolivre/data/shipping_cost_ml/"
        filelist= os.listdir(path)
        paths = [f"{path}{file}" for file in filelist]

        for path in paths:
            with open(path, "r", encoding="utf-8") as json_file:
                data = [json.load(json_file)]

            print(f"trying to load {path} to stg schema")
            info = pipeline.run(data, table_name="stg_mercadolivre_sh", write_disposition="append")

            print(info)
            print(pipeline.last_trace)
        # Print the load summary
    