def run_empty_shopee_fact_table(test_run):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = "./dbt/e_commerce_sales"
        PROJECT_PATH = "./dbt/e_commerce_sales"
    else:
        PROFILE_PATH = "/opt/airflow/dbt/e_commerce_sales"
        PROJECT_PATH = "/opt/airflow/dbt/e_commerce_sales"

    dbt = dbtRunner()
    cli_args = [
                    "run",
                    "entry_shopee shopee_new_id  supplies",
                    "--empty",
                    "--profiles-dir",
                    PROFILE_PATH,
                    "--project-dir",
                    PROJECT_PATH
               ]

    result = dbt.invoke(cli_args)
    if result.success:
        print("Run successfully finished.")
    else:
        print("dbt deps failed!")
        print(result.exception)
        raise RuntimeError("dbt run failed")

def test_shopee_fact_table(test_run):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = "./dbt/e_commerce_sales"
        PROJECT_PATH = "./dbt/e_commerce_sales"
    else:
        PROFILE_PATH = "/opt/airflow/dbt/e_commerce_sales"
        PROJECT_PATH = "/opt/airflow/dbt/e_commerce_sales"

    dbt = dbtRunner()
    cli_args = [
                    "test",
                    "--select",
                    "is_profit_correct",
                    "--profiles-dir",
                    PROFILE_PATH,
                    "--project-dir",
                    PROJECT_PATH
               ]

    result = dbt.invoke(cli_args)
    if result.success:
        print("Test successfully finished.")
    else:
        print("dbt deps failed!")
        print(result.exception)
        raise RuntimeError("dbt run failed")
    
    if test_run:
        return result.success
    