from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator

from scripts.extraction.mercadolivre.create_shipping_id_list import make_shipping_file
from scripts.extraction.mercadolivre.extract_seller_shipping_cost import get_shipping_id
from scripts.loading.mercadolivre.load_shipping_cost import postgres_ingestion_sh_costs

with DAG(
    dag_id = '04_ELT_shipping_file_prod',
    description="Creates the csv shipping id file to extract shipping costs from Mercado Livre's API, then extracts and load it to the DW.",
    start_date=None,
    schedule=None,
    tags = ['prod']
) as dag:
    start_dag = EmptyOperator(
                task_id='start_dag'
            )
    
    make_csv_file = PythonOperator(
                task_id='make_csv_file',
                python_callable=make_shipping_file,
                op_kwargs = {'test_run': False, 'env': 'prod'}
            )

    extract_ml_ship_cost = PythonOperator(
                task_id='extract_from_API',
                python_callable=get_shipping_id,
                op_kwargs = {'test_run': False, 'env': 'prod'}
            )
    
    load_sh_costs = PythonOperator(
                    task_id='load_sh_costs',
                    python_callable=postgres_ingestion_sh_costs,
                    op_kwargs = {'test_run': False, 'env': 'prod'}
                )

    start_dag >> make_csv_file >> extract_ml_ship_cost >> load_sh_costs