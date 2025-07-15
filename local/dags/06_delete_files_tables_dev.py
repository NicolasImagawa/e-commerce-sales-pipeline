from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator

from scripts.deletion.delete_files import delete_input_files
from scripts.deletion.delete_tables import delete_entry_tables


with DAG(
    dag_id = '06_delete_entry_data_dev',
    description="Deletes the data and files loaded to the entry tables. It does not delete downstream tables.",
    start_date=None,
    schedule=None,
    tags = ['dev']
) as dag:
    start_dag = EmptyOperator(
                task_id='start_dag'
            )

    delete_tables = PythonOperator(
                task_id='delete_tables',
                python_callable = delete_entry_tables,
                op_kwargs = {'env': 'dev'}
            )

    delete_ml_files = PythonOperator(
                task_id='delete_ml_files',
                python_callable = delete_input_files,
                op_kwargs = {'path': "/opt/airflow/data/mercadolivre/raw/dev/", 'file_extension': "*.json"}
            )
    
    delete_ml_sh_files = PythonOperator(
                task_id='delete_ml_sh_files',
                python_callable = delete_input_files,
                op_kwargs = {'path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/", 'file_extension': "*.json"}
            )
    
    delete_shopee_files = PythonOperator(
            task_id='delete_shopee_files',
            python_callable = delete_input_files,
            op_kwargs = {'path': "/opt/airflow/data/shopee/raw/dev/", 'file_extension': "*.xlsx"}
        )

    delete_sh_ids_files = PythonOperator(
            task_id='delete_sh_ids_files',
            python_callable = delete_input_files,
            op_kwargs = {'path': "/opt/airflow/data/mercadolivre/shipping_cost_ml/dev/", 'file_extension': "*.csv"}
        )

    start_dag >> [delete_tables, delete_ml_files, delete_ml_sh_files, delete_shopee_files, delete_sh_ids_files]