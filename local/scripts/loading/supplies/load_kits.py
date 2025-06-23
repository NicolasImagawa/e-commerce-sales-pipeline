def postgres_ingestion_kits(env):
    import pandas as pd #pip install openpyxl
    from sqlalchemy import create_engine

    if env == 'prod':
        path = f"/opt/airflow/data/supplies/clean/prod/kit_components.csv"
    elif env == 'dev':
        path = f"/opt/airflow/data/supplies/clean/dev/dev_kit_components.csv"

    df = pd.read_csv(path, encoding='utf-8')

    if env == 'prod':
        db = 'sales_db'
    elif env == 'dev':
        db = 'dev_sales_db'

    engine = create_engine(f'postgresql://airflow:airflow@pgdatabase:5432/{db}')

    try:
        print(f"Loading file {path} to {env} sales_db")
        df.to_sql(name="kit_components", schema="supplies", con=engine, if_exists='replace', index=False)
        print(f"Data in {path} successfully loaded.")
    except Exception as e:
        print(f"An exception has occured on file {path}.")
        print("--------------------------------------------------")
        print(e)
        print("--------------------------------------------------")