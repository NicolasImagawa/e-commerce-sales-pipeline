from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from pathlib import Path
import sys
import datetime as dt

sys.path.insert(0, str(Path(__file__).parent.parent))

from extraction.mercadolivre.script.send_data import postgres_ingestion_ml
from extraction.mercadolivre.script.send_shipping_cost import postgres_ingestion_sh_costs
from extraction.shopee.script.send_data import postgres_ingestion_shopee
from extraction.supplies.script.load_prices import postgres_ingestion_costs
from extraction.supplies.script.load_kits import postgres_ingestion_kits


with DAG (
    dag_id = '03_load_data',
    description="Data loading DAG",
    start_date=None,
    schedule_interval=None
) as dag:

    start_dag = EmptyOperator(
                    task_id='start_extraction_dag',
                )

    load_mercadolivre = PythonOperator(
                    task_id='load_mercadolivre',
                    python_callable=postgres_ingestion_ml,
                    op_kwargs = {'test_run': False}
                )

    load_shopee = PythonOperator(
                    task_id='load_shopee',
                    python_callable=postgres_ingestion_shopee,
                    op_kwargs = {'test_run': False}
                )
    
    load_prod_cost = PythonOperator(
                    task_id='load_prod_cost',
                    python_callable=postgres_ingestion_costs
                )

    load_kits = PythonOperator(
                    task_id='load_kits',
                    python_callable=postgres_ingestion_kits
                )
    
    load_sh_costs = PythonOperator(
                    task_id='load_sh_costs',
                    python_callable=postgres_ingestion_sh_costs,
                    op_kwargs = {'test_run': False}
                )
    
    start_dag >> [load_mercadolivre, load_shopee, load_prod_cost, load_kits, load_sh_costs]