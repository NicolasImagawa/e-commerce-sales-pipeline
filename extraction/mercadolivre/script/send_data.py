def postgres_ingestion_ml(test_run):
    import dlt
    from dlt.destinations import postgres
    import json
    import os
    import pathlib
    from dotenv import load_dotenv

    load_dotenv()

    if test_run:
        dir = "./extraction/mercadolivre/data/raw/sample.json"
        files = [dir]
        creds = "postgresql://airflow:airflow@localhost:5432/sales_db"
    else:
        dir = "./extraction/mercadolivre/data/raw/"
        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]
        creds = "postgresql://airflow:airflow@pgdatabase:5432/sales_db"


    pipeline = dlt.pipeline(
        pipeline_name="mercadolivre_data",
        dataset_name="entry",
        destination=postgres(credentials=creds),
    )
    
    if test_run:
        dir = "./extraction/mercadolivre/data/raw/sample.json"
        files = [dir]
    else:
        dir = "./extraction/mercadolivre/data/raw/"
        filelist = os.listdir(dir)
        files = [f"{dir}{file}" for file in filelist]

    # count_sell_data = 0
    # for file in files:
    #     if pathlib.Path(file).suffix == ".json":
    #         with open(file, "r", encoding="utf-8") as json_file:
    #             data = json.load(json_file)

    #         if len(data[count_sell_data]["tags"]) == 0:
    #             data[count_sell_data]["tags"] = ["N/A"]
                
    #             with open(file, "w") as editted_file:
    #                 json.dump(data, editted_file)

    #         count_sell_data += 1

    for file in files:

        if pathlib.Path(file).suffix == ".json":
            with open(file, "r", encoding="utf-8") as json_file:
                data = [json.load(json_file)]

            # if len(data["tags"]) == 0:
            #     data["tags"] = ["N/A"]

            print(f"trying to load {file} to sales_db")
            info = pipeline.run(data, table_name="entry_mercadolivre", write_disposition="append")

            print(info)
            print(pipeline.last_trace)
            result = 1
        else:
            print(f"[WARNING] - file {file} does not have .json extension and could not be loaded.")
            result = -1
            
    return result
