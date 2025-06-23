from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.transformation.install_deps import install_dependencies
from scripts.transformation.run_dbt import transform_data

with DAG(
    dag_id = '05_transform_data_dev',
    description="Data transformation DAG",
    start_date=None,
    schedule=None,
    tags = ['dev']
) as dag:
    start_dag = EmptyOperator(
                task_id='start_dag'
            )
    
    install_dbt_deps = PythonOperator(
                task_id='install_dbt_deps',
                python_callable=install_dependencies,
                op_kwargs = {'test_run': False, 'target': "dev"}
            )

    transform_dbt = PythonOperator(
                task_id='run_dbt',
                python_callable=transform_data,
                op_kwargs = {'target': "dev"}
            )
    
    start_dag >> install_dbt_deps >> transform_dbt
    