def install_dependencies(test_run: bool, target: str) -> None:
    from config.config import DBT_PROFILE_PATH, DBT_PROJECT_PATH, TEST_PROFILE_PATH, TEST_PROJECT_PATH
    
    from dbt.cli.main import dbtRunner, dbtRunnerResult

    if test_run:
        PROFILE_PATH = TEST_PROFILE_PATH
        PROJECT_PATH = TEST_PROJECT_PATH
    else:
        PROFILE_PATH = DBT_PROFILE_PATH
        PROJECT_PATH = DBT_PROJECT_PATH

    dbt = dbtRunner()
    cli_args = [
                    "deps",
                    "--profiles-dir",
                    PROFILE_PATH,
                    "--project-dir",
                    PROJECT_PATH,
                    "--target",
                    target
               ]

    result = dbt.invoke(cli_args)
    if result.success:
        print("Dependencies sucessfully installed.")
    else:
        print("dbt deps failed!")
        print(result.exception)
        raise RuntimeError("dbt deps failed")
    