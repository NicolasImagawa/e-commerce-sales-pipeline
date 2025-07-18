def postgres_ingestion_costs(env: str) -> None:
    import pathlib
    import sys

    sys.path.append(str(pathlib.Path(__file__).parent.parent.parent.parent))

    from config.config import PATHS
    
    import pandas as pd #pip install openpyxl
    from sqlalchemy import create_engine

    if env == 'prod':
        path = PATHS['load_prices']['prod']['path']
    elif env == 'dev':
        path = PATHS['load_prices']['dev']['path']

    df = pd.read_csv(path, encoding='utf-8')

    df["begin_date"] = pd.to_datetime(df["begin_date"])
    df["end_date"] = pd.to_datetime(df["end_date"])

    begin_date = df["begin_date"]
    end_date = df["end_date"]

    print(f"column begin_date is {begin_date.dtype}")
    print(f"column end_date is {end_date.dtype}")

    if env == 'prod':
        db = 'sales_db'
    elif env == 'dev':
        db = 'dev_sales_db'

    engine = create_engine(f'postgresql://airflow:airflow@pgdatabase:5432/{db}')

    try:
        print(f"Loading file {path} to {env} sales_db")
        df.to_sql(name="product_sku_cost", schema="supplies", con=engine, if_exists='replace', index=False)
        print(f"Data in {path} successfully loaded.")
    except Exception as e:
        print(f"An exception has occured on file {path}.")
        print("--------------------------------------------------")
        print(e)
        print("--------------------------------------------------")
