from pathlib import Path
import sys
import psycopg2
from psycopg2 import sql

sys.path.insert(0, str(Path(__file__).parent.parent))

from dbt_files.install_deps import install_dependencies
from dbt_files.prepare_testing import run_empty_shopee_tables
from dbt_files.prepare_testing import run_shopee_fact_table

def test_transform():
    print("\n=================== test_transformation.py started ===================")
    conn = psycopg2.connect(database = "postgres", user = "airflow", host= 'localhost', password = "airflow", port = 5432) #uses maintenance db to create the infrastructure
    cursor = conn.cursor()
    conn.autocommit = True
    
    cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier("sales_db")))

    conn = psycopg2.connect(database = "sales_db", user = "airflow", host= 'localhost', password = "airflow", port = 5432)
    cursor.execute(sql.SQL("CREATE SCHEMA {}").format(sql.Identifier("stg")))
    cursor.execute(sql.SQL("CREATE TABLE IF NOT EXISTS {}").format(sql.Identifier("stg.stg_shopee")))

    print("\n******* installing dependencies *******")
    install_dependencies(test_run = True)
    print("\n******* running empty parent tables *******")
    run_empty_shopee_tables(test_run = True)
    print("\n******* testing shopee fact table *******")
    test_results = run_shopee_fact_table(test_run = True)

    cursor.execute(sql.SQL("DROP DATABASE {}").format(sql.Identifier("sales_db")))
    print("=================== test_transformation.py finished ===================")

    assert test_results == True
