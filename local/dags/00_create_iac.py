from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
import sys
from pathlib import Path
import datetime as dt

sys.path.insert(0, str(Path(__file__).parent.parent))  # 0: highest priority when including the folder common to dags and the extraction scripts.

from scripts.IaC.run_terraform import run_terraform

tf_create_db_dir = "/opt/airflow/terraform/create_db"
tf_create_schemas_dir = "/opt/airflow/terraform/create_schemas"

with DAG(
    dag_id = '00_create_IAC',
    start_date=None,
    schedule=None,
    description='Creates database and schema',
    tags = ['prod', 'dev']
) as dag:
    start_dag = EmptyOperator(
                task_id = 'start_dag'
        )
    
    create_database = PythonOperator(
                task_id='create_database',
                python_callable=run_terraform,
                op_kwargs = {'dir': tf_create_db_dir}
        )

    create_schemas = PythonOperator(
            task_id='create_schemas',
            python_callable=run_terraform,
            op_kwargs = {'dir': tf_create_schemas_dir}
    )

    start_dag >> create_database >> create_schemas