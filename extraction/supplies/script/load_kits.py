def postgres_ingestion_kits():
    import pandas as pd #pip install openpyxl
    from sqlalchemy import create_engine

    path = "/opt/airflow/cleaning/entry_data/clean/kit_components.csv"

    df = pd.read_csv(path, encoding='utf-8')

    engine = create_engine(f'postgresql://airflow:airflow@pgdatabase:5432/sales_db')

    try:
        print(f"Loading file {path} to sales_db")
        df.to_sql(name="kit_components", schema="supplies", con=engine, if_exists='replace', index=False)
        print(f"Data in {path} successfully loaded.")
    except Exception as e:
        print(f"An exception has occured on file {path}.")
        print("--------------------------------------------------")
        print(e)
        print("--------------------------------------------------")