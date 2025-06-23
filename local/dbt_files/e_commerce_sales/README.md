## About the dbt transformations

For this pipeline, dbt runs with Apache Airflow, including its dependencies.

Currently, there are no seeds and the schema.yml file has info about the entry data loaded to the warehouse.

The information about the models can be found on: https://github.com/NicolasImagawa/e-commerce-sales-pipeline/tree/main/local/dbt_files/e_commerce_sales/models

The lineage is the following for Mercado Livre and Shopee, respectively:

<br>

![image](https://github.com/user-attachments/assets/ba9f5645-c764-41e1-a03d-6068e0e97341)

<br>

<br>

![image](https://github.com/user-attachments/assets/9c021778-c183-4cc5-b744-a5866218ab09)

<br>

The dbt docs can be generated with the following commands on the CLI:

1. winpty docker exec -it local-airflow-webserver-1 sh OR docker exec -it local-airflow-webserver-1 sh
2. cd dbt_files/e_commerce_sales
3. dbt docs generate
4. dbt serve --port 8001 --host 0.0.0.0
   
Then, go to http://localhost:8001/ on your browser.

The information about each table, uniqueness tests, warnings and errors that the schema.yml file can handle are under development.
