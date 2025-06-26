def clean_cost_data (test_run: bool, env: str) -> dict: #if testing, returns a dict, otherwise, None.
    from config.config import PATHS

    import pandas as pd

    if test_run:
        cost_data_path = PATHS['adjust_cost_data']['test']['cost_data_path']
        output_path = PATHS['adjust_cost_data']['test']['output_path']
    else:
        if env == 'prod':
            cost_data_path = PATHS['adjust_cost_data']['prod']['cost_data_path']
            output_path = PATHS['adjust_cost_data']['prod']['output_path']
        else:
            cost_data_path = PATHS['adjust_cost_data']['dev']['cost_data_path']
            output_path = PATHS['adjust_cost_data']['dev']['output_path']
    
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
