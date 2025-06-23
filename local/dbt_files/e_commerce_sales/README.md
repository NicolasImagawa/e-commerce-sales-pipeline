## About the dbt transformations

For this pipeline, dbt runs with Apache Airflow, including its dependencies.

Currently, there are no seeds and the schema.yml file has info about the entry data loaded to the warehouse.

The information about the models can be found on: https://github.com/NicolasImagawa/e-commerce-sales-pipeline/tree/main/local/dbt_files/e_commerce_sales/models

The dbt docs can be generated with `dbt docs generate`, followed by `dbt docs serve` accessed with http://localhost:8080 as default.

The information about each table, uniqueness tests, warnings and errors that the schema.yml file can handle are under development.
