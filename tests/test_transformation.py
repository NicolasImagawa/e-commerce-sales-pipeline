from pathlib import Path
import sys
import psycopg2
from psycopg2 import sql

sys.path.insert(0, str(Path(__file__).parent.parent))

from dbt_files.install_deps import install_dependencies
from dbt_files.unit_test import run_empty_shopee_fact_table
from dbt_files.unit_test import  test_shopee_fact_table

def dbt_unit_test():
    conn = psycopg2.connect(database = "postgres", user = "airflow", host= 'localhost', password = "airflow", port = 5432) #uses maintenance db to create the infrastructure
    cursor = conn.cursor()
    conn.autocommit = True
    
    cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier("sales_db")))

    install_dependencies()
    run_empty_shopee_fact_table()
    test_results = test_shopee_fact_table(test_run = True)

    cursor.execute(sql.SQL("DROP DATABASE {}").format(sql.Identifier("sales_db")))

    assert test_results == True
