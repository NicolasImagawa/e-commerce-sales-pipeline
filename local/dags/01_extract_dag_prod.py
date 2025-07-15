from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
import datetime as dt

from scripts.extraction.mercadolivre.get_access_token import get_access_token
from scripts.extraction.mercadolivre.extract_ml_data import extract_mercado

date_init = "2024-07-01T00:00:00.000-03:00"
date_end = "2025-05-01T00:00:00.000-03:00"
# date_init = "2024-05-01T00:00:00.000-03:00"
# date_end = "2025-06-01T00:00:00.000-03:00"

with DAG (
    dag_id = '01_extract_data_prod',
    description="Data extraction DAG",
    start_date=None,
    schedule_interval=None,
    catchup=False,
    tags = ['prod']
) as dag:

    start_dag = EmptyOperator(
                    task_id='start_extraction_dag'
                )

    ml_access_token = PythonOperator(
                    task_id = 'ml_access_token',
                    python_callable = get_access_token,
                    op_kwargs = {'test_run': False}
                )

    extract_ml = PythonOperator(
                    task_id = 'extract_ml',
                    python_callable = extract_mercado,
                    op_kwargs = {'test_run': False, 'order_init_date': date_init, 'order_end_date': date_end, 'env': 'prod'}
                )

    # extract_shopee is not available due to platform issues

    start_dag >> ml_access_token >> extract_ml