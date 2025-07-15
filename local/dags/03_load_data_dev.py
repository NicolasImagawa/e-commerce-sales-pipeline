from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
import datetime as dt

from scripts.loading.mercadolivre.load_data import postgres_ingestion_ml
from scripts.loading.shopee.load_data import postgres_ingestion_shopee
from scripts.loading.supplies.load_prices import postgres_ingestion_costs
from scripts.loading.supplies.load_kits import postgres_ingestion_kits


with DAG (
    dag_id = '03_load_data_dev',
    description="Data loading DAG",
    start_date=None,
    schedule_interval=None,
    tags = ['dev']
) as dag:

    start_dag = EmptyOperator(
                    task_id='start_extraction_dag',
                )

    load_mercadolivre = PythonOperator(
                    task_id='load_mercadolivre',
                    python_callable=postgres_ingestion_ml,
                    op_kwargs = {'test_run': False, 'env': 'dev'}
                )

    load_shopee = PythonOperator(
                    task_id='load_shopee',
                    python_callable=postgres_ingestion_shopee,
                    op_kwargs = {'test_run': False, 'env': 'dev'}
                )
    
    load_prod_cost = PythonOperator(
                    task_id='load_prod_cost',
                    python_callable=postgres_ingestion_costs,
                    op_kwargs = {'env': 'dev'}
                )

    load_kits = PythonOperator(
                    task_id='load_kits',
                    python_callable=postgres_ingestion_kits,
                    op_kwargs = {'env': 'dev'}
                )
    
    start_dag >> [load_mercadolivre, load_shopee, load_prod_cost, load_kits]