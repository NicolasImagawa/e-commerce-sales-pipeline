def postgres_ingestion_costs():
    import pandas as pd #pip install openpyxl
    from sqlalchemy import create_engine

    path = "/opt/airflow/cleaning/entry_data/clean/clean_cost_data.csv"

    df = pd.read_csv(path, encoding='utf-8')

    df["begin_date"] = pd.to_datetime(df["begin_date"])
    df["end_date"] = pd.to_datetime(df["end_date"])

    begin_date = df["begin_date"]
    end_date = df["end_date"]

    print(f"column begin_date is {begin_date.dtype}")
    print(f"column end_date is {end_date.dtype}")

    engine = create_engine(f'postgresql://airflow:airflow@pgdatabase:5432/sales_db')

    try:
        print(f"Loading file {path} to sales_db")
        df.to_sql(name="product_sku_cost", schema="supplies", con=engine, if_exists='replace', index=False)
        print(f"Data in {path} successfully loaded.")
    except Exception as e:
        print(f"An exception has occured on file {path}.")
        print("--------------------------------------------------")
        print(e)
        print("--------------------------------------------------")
