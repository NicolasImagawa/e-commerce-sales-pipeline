def clean_cost_data (test_run):
    import pandas as pd

    if test_run:
        cost_data_path = "./entry_data/raw/cleaning_sample.csv"
        output_path = "./entry_data/clean/clean_sample.csv"
    else:
        cost_data_path = "/opt/airflow/cleaning/entry_data/raw/cost_data.csv"
        output_path = "/opt/airflow/cleaning/entry_data/clean/clean_cost_data.csv"
    
    df = pd.read_csv(cost_data_path)

    df["cost"] = df["cost"].str.replace(",", ".")
    df["cost"] = df["cost"].fillna("0")
    df["cost"] = df["cost"].astype(float).apply(lambda x: '{:,.2f}'.format(x))


    df["begin_date"] = pd.to_datetime(df["begin_date"].str.strip(), format='%d/%m/%Y',  utc = True)
    df["end_date"] = pd.to_datetime(df["end_date"].str.strip(), format='%d/%m/%Y',  utc = True)

    df["end_date"] = df["end_date"] + pd.Timedelta(hours = 23, minutes=59, seconds=59)

    df.to_csv(output_path, encoding="utf-8", index=False)
    print(f"Saved file on {output_path}")
    
    if test_run:
        test_results = {
            "begin_date_type": df["begin_date"].dtype,
            "end_date_type": df["end_date"].dtype,
            "begin_date_nulls": sum(df["begin_date"].isnull),
            "cost_nulls_nans": sum(df["cost"].isnull) + sum(df["cost"].isna)
        }

        return test_results
