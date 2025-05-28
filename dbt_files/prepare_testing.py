def run_empty_shopee_tables(test_run):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = "./dbt_files/e_commerce_sales/tests"
        PROJECT_PATH = "./dbt_files/e_commerce_sales"
    else:
        PROFILE_PATH = "/opt/airflow/dbt_files/e_commerce_sales"
        PROJECT_PATH = "/opt/airflow/dbt_files/e_commerce_sales"

    dbt = dbtRunner()
    # cli_args = [
    #                 "run",
    #                 "--select",
    #                 "stg_shopee shopee_new_id kit_components product_sku_cost",
    #                 "--empty",
    #                 "--profiles-dir",
    #                 PROFILE_PATH,
    #                 "--project-dir",
    #                 PROJECT_PATH
    #            ]
    cli_args = [
                    "build",
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
        print("dbt preparation failed!")
        print(result.exception)
        raise RuntimeError("dbt run failed")
        
def run_shopee_fact_table(test_run):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = "./dbt_files/e_commerce_sales/tests"
        PROJECT_PATH = "./dbt_files/e_commerce_sales"
    else:
        PROFILE_PATH = "/opt/airflow/dbt_files/e_commerce_sales"
        PROJECT_PATH = "/opt/airflow/dbt_files/e_commerce_sales"

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
        print("************Test successfully finished.************")
        print(result.result)
    else:
        print("dbt deps failed!")
        print(result.exception)
        raise RuntimeError("dbt run failed")
    
    if test_run:
        return result.success
    