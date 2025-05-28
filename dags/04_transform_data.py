from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))

from dbt_files.run_dbt import transform_data
from dbt_files.install_deps import install_dependencies

with DAG(
    '04_transform_data',
    description="Data transformation DAG",
    start_date=None,
    schedule=None
) as dag:
    start_dag = EmptyOperator(
                task_id='start_dag'
            )
    
    install_dbt_deps = PythonOperator(
                task_id='install_dbt_deps',
                python_callable=install_dependencies,
                op_kwargs = {'test_run': False}
            )

    transform_dbt = PythonOperator(
                task_id='run_dbt',
                python_callable=transform_data
            )
    
    start_dag >> install_dbt_deps >> transform_dbt
    