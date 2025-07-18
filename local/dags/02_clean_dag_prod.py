from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
import datetime as dt

from scripts.cleaning.adjust_cost_data import clean_cost_data

with DAG (
    dag_id = '02_clean_data_prod',
    description="Data cleaning DAG",
    start_date=None,
    schedule_interval=None,
    tags = ['prod']
) as dag:

    start_dag = EmptyOperator(
                    task_id='start_extraction_dag',
                    dag = dag
                )

    clean_supplies_prices = PythonOperator(
                    task_id='clean_cost_data',
                    python_callable = clean_cost_data,
                    op_kwargs = {'test_run': False, 'env': 'prod'}
                )

    start_dag >> clean_supplies_prices