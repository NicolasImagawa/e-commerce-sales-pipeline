def transform_data(target: str) -> None:
    from config.config import DBT_PROFILE_PATH, DBT_PROJECT_PATH
    
    from dbt.cli.main import dbtRunner

    dbt = dbtRunner()
    cli_args = [
                    "run",
                    "--profiles-dir",
                    DBT_PROFILE_PATH,
                    "--project-dir",
                    DBT_PROJECT_PATH,
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
