def clean_cost_data (test_run, env):
    import pandas as pd

    if test_run:
        cost_data_path = "./local/data/supplies/unit_test/raw/raw_sample.csv"
        output_path = "./local/data/supplies/unit_test/clean/clean_sample.csv"
    else:
        if env == 'prod':
            cost_data_path = "/opt/airflow/data/supplies/raw/prod/cost_data.csv"
            output_path = "/opt/airflow/data/supplies/clean/prod/clean_cost_data.csv"
        else:
            cost_data_path = "/opt/airflow/data/supplies/raw/dev/dev_cost_data.csv"
            output_path = "/opt/airflow/data/supplies/clean/dev/dev_clean_cost_data.csv"
    
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
            "begin_date_nulls": df["begin_date"].isna().sum().sum(),
            "cost_nulls_nans": df["cost"].isna().sum().sum()
        }

        return test_results
