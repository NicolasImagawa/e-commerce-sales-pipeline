# Overview
This open-source data pipeline shows sales results from two major e-commerce platforms in Brazil (Mercado Livre and Shopee) through an ELT pipeline that stores data in an on-premises star-schema data warehouse. 
The pipeline runs can be configured as the users see fit by changing the Apache Airflow DAGs.

## Tools and technologies used for the pipeline development
The following picture shows how the pipeline works end-to-end.

**Picture here**

- Data Warehouse: PostgreSQL;
- Infrastructure: Terraform creates all databases and schemas in the warehouse;
- Extraction: Python to handle REST API requests;
- Cleaning: Pandas;
- Loading:
  - dlt and Python: For Mercado Livre .json data;
  - PostgreSQL and Python: to load Shopee .xlsx data;
  - PostgreSQL: to load user-defined .csv files regarding costs and product relations.
- Transformation: dbt;
- Orchestration: Apache Airflow;
- Management and quering: pgAdmin.

## Charts and reports
The pipeline supports the current default charts:
- Margin before taxes and operational costs, for a given period;
- Top 10 most sold products for a given period;
- Sales on a given period.

Any other table or view might be created by the user.

*****Create reports*****
*****Create charts*****

## Requirements
To run this pipeline, the user needs:
1. A Mercado Livre seller account;
2. A Mercado Livre application [(more on that here - PT/BR)](https://developers.mercadolivre.com.br/en/crie-uma-aplicacao-no-mercado-livre);
3. A Shopee seller account;
4. Docker and docker compose on your machine. Docker Desktop is also possible;
5. To clone this repo;
6. To have preferably Python 3.9 or a virtual environment equivalent on its machine.

## Running the pipeline
To run the pipeline, first run the following command on the project's root through the CLI.
```
docker build -t airflow_e_commerce_sales:v001 .
```
Then, please run this command:
```
docker-compose up -d
```
After creating the containers, check if the following port has Apache Airflow running on it.
```
https://localhost:8081
```
