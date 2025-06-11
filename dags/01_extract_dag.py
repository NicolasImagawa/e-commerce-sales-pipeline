from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
import sys
from pathlib import Path
import datetime as dt

sys.path.insert(0, str(Path(__file__).parent.parent))  # 0: highest priority when including the folder common to dags and the extraction scripts.

from extraction.mercadolivre.script.get_access_token import get_access_token
from extraction.mercadolivre.script.extract_data import extract_mercado
from extraction.mercadolivre.script.get_seller_shipping_cost import get_shipping_id

with DAG (
    dag_id = '01_extract_data',
    description="Data extraction DAG",
    start_date=None,
    schedule_interval=None,
    catchup=False
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
                    op_kwargs = {'test_run': False}
                )

    # extract_shopee is not available due to platform issues

    start_dag >> ml_access_token >> extract_ml