import sys
from pathlib import Path
import psycopg2
from psycopg2 import sql

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.send_shipping_cost import postgres_ingestion_sh_costs

def test_load_ml():
    print("=================== test_load_shipping.py started ===================")
    conn = psycopg2.connect(database = "postgres", user = "airflow", host= 'localhost', password = "airflow", port = 5432) #uses maintenance db to create the infrastructure
    cursor = conn.cursor()
    conn.autocommit = True
    
    cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier("sales_db")))

    test_results = postgres_ingestion_sh_costs(test_run=True)

    cursor.execute(sql.SQL("DROP DATABASE {}").format(sql.Identifier("sales_db")))

    cursor.close()

    assert test_results == 1
    print("=================== test_load_shipping.py finished ===================")