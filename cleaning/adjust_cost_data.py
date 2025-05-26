def clean_cost_data ():
    import pandas as pd

    cost_data_path = "/opt/airflow/cleaning/entry_data/raw/cost_data.csv"
    df = pd.read_csv(cost_data_path)

    df["cost"] = df["cost"].str.replace(",", ".")
    df["cost"] = df["cost"].fillna("0")
    df["cost"] = df["cost"].astype(float).apply(lambda x: '{:,.2f}'.format(x))


    df["begin_date"] = pd.to_datetime(df["begin_date"].str.strip(), format='%d/%m/%Y',  utc = True)
    df["end_date"] = pd.to_datetime(df["end_date"].str.strip(), format='%d/%m/%Y',  utc = True)

    df["end_date"] = df["end_date"] + pd.Timedelta(hours = 23, minutes=59, seconds=59)

    output_path = "/opt/airflow/cleaning/entry_data/clean/clean_cost_data.csv"
    df.to_csv(output_path, encoding="utf-8", index=False)
    print(f"Saved file on {output_path}")
