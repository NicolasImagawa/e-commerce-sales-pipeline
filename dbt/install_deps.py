def install_dependencies():
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    PROFILE_PATH = "/opt/airflow/dbt/e_commerce_sales"
    PROJECT_PATH = "/opt/airflow/dbt/e_commerce_sales"

    dbt = dbtRunner()
    cli_args = [
                    "deps",
                    "--profiles-dir",
                    PROFILE_PATH,
                    "--project-dir",
                    PROJECT_PATH
               ]

    result = dbt.invoke(cli_args)
    if result.success:
        print("Dependencies sucessfully installed.")
    else:
        print("dbt deps failed!")
        print(result.exception)
        raise RuntimeError("dbt deps failed")