def install_dependencies(test_run):
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = "./dbt_files/e_commerce_sales"
        PROJECT_PATH = "./dbt_files/e_commerce_sales"
    else:
        PROFILE_PATH = "/opt/airflow/dbt_files/e_commerce_sales"
        PROJECT_PATH = "/opt/airflow/dbt_files/e_commerce_sales"

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
    