from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator
from pathlib import Path
import sys
import datetime as dt

sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.cleaning.adjust_cost_data import clean_cost_data

with DAG (
    dag_id = '02_clean_data_dev',
    description="Data cleaning DAG",
    start_date=None,
    schedule_interval=None,
    tags = ['dev']
) as dag:

    start_dag = EmptyOperator(
                    task_id='start_extraction_dag',
                    dag = dag
                )

    clean_supplies_prices = PythonOperator(
                    task_id='clean_cost_data',
                    python_callable = clean_cost_data,
                    op_kwargs = {'test_run': False, 'env': 'dev'}
                )

    start_dag >> clean_supplies_prices