def transform_data(target):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    PROFILE_PATH = "/opt/airflow/dbt_files/e_commerce_sales"
    PROJECT_PATH = "/opt/airflow/dbt_files/e_commerce_sales"

    dbt = dbtRunner()
    cli_args = [
                    "run",
                    "--profiles-dir",
                    PROFILE_PATH,
                    "--project-dir",
                    PROJECT_PATH,
                    "--target",
                    target
               ]

    result = dbt.invoke(cli_args)
    if result.success:
        print("Transformation sucessfully done.")
    else:
        print("dbt run failed!")
        print(result.exception)
        raise RuntimeError("dbt run failed")