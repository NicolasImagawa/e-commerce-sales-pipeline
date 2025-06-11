# Overview
This open-source data pipeline shows sales results from two major e-commerce platforms in Brazil (Mercado Livre and Shopee) through an ELT pipeline that stores data in an on-premises star-schema data warehouse. 
The pipeline runs can be configured as the users see fit by changing the Apache Airflow DAGs.

## Contents
- [Tools and technologies used for the pipeline development](#tools-and-technologies-used-for-the-pipeline-development)
- [Charts](#charts)
- [Requirements](#requirements)
- [Running the pipeline](#running-the-pipeline)
  - [Running Docker](#running-docker)
  - [Accessing the API](#accessing-the-api)
  - [Running the DAGs](#running-the-dags)
  - [Accessing the Data Warehouse](#accessing-the-data-warehouse)
- [Contact](#contact)
  
## Tools and technologies used for the pipeline development
The following picture shows how the pipeline works end-to-end.
  
  <br>
  
![image](https://github.com/user-attachments/assets/7e739c09-68b1-464a-b555-45b0835eeb7e)

  <br>
  
- Data Warehouse: PostgreSQL;
- Infrastructure: Terraform creates all additional databases and schemas in the warehouse;
- Extraction: Python to handle REST API requests;
- Cleaning: Pandas;
- Loading:
  - dlt and Python: For Mercado Livre .json data;
  - PostgreSQL and Python: to load Shopee .xlsx data;
  - PostgreSQL: to load user-defined .csv files regarding costs and product relations.
- Transformation: dbt;
- Orchestration: Apache Airflow;
- Management and quering: pgAdmin.

## Charts
The pipeline supports the current default charts:
- Margin before taxes and operational costs, for a given period;
  
  <br>
  
  ![image](https://github.com/user-attachments/assets/2d231a9c-a978-44fc-a22d-f3f74d2dcfb8)

- Most sold products for a given period;
  
  <br>
  
![image](https://github.com/user-attachments/assets/4d209d63-9964-4b5b-9df3-a905b8d0733a)

- Sales on a given period.
  
  <br>
  
![image](https://github.com/user-attachments/assets/33650448-2e85-4b3f-92f3-96ff38691e54)

<br>

Any other table or view might be created by the user.

## Requirements
To run this pipeline, the user needs:
1. A Mercado Livre seller account;
2. A Mercado Livre application [(more on that here - PT/BR)](https://developers.mercadolivre.com.br/en/crie-uma-aplicacao-no-mercado-livre);
3. A Shopee seller account;
4. Docker and docker compose on your machine. Docker Desktop is also possible;
5. To clone this repo;
6. To have preferably Python 3.9 or a virtual environment equivalent on its machine.

## Running the pipeline

### Running Docker
To run the pipeline, first run the following command on the project's root through the CLI.
```
docker build -t airflow_e_commerce_sales:v001 .
```
Then, please run this command:
```
docker-compose up -d
```
After creating the containers, use your browser to check if the following port has Apache Airflow running on it.
```
https://localhost:8081
```
The default credentials are `airflow` for both the username and password.

### Accessing the API
Now, create a `.env` file on the project's root to access Mercado Livre's API and get its access token with the following parameters:
- `SELLER_ID` = Obtained on your 
- `CLIENT_ID` = Access [https://developers.mercadolivre.com.br/devcenter]
- `CLIENT_SECRET` = Click on the chosen mercadolivre devcenter application, then the value will be found under "Chave Secreta" on the Portuguese UI;
- `REDIRECT_URI` = Default value is "https://github.com/NicolasImagawa"
- `SHIPPING_ID_TEST_1` = for testing only, not necessary
- `LIST_COST` = for testing only, not necessary
-  `CODE` = Change $CLIENT_ID on the following link and paste it on your browser \
            https://auth.mercadolivre.com.br/authorization?response_type=code&$CLIENT_ID&redirect_uri=https://github.com/NicolasImagawa \
            Then, get the code from the reponse URL. It starts with "TG-" followed be an alphanumeric sequence.
> [!IMPORTANT]
> `CODE` lasts for about 10 minutes, so if an error occurs while trying to get the Access Token that might be the case.

> [!TIP]
> If this is your first time accessing Mercado Livre's API, you can learn more about it on the following webpage: https://developers.mercadolivre.com.br/pt_br/crie-uma-aplicacao-no-mercado-livre

### Running the DAGs
After that, please go again to again to Airflow on the following port:
```
https://localhost:8081
```
Then, run each DAG (or "play buttons" if you are not familiar with some concepts) on its numerical order after each one of them is finished. This is the UI to be used:
<br>
![image](https://github.com/user-attachments/assets/5dd4d02f-b2e1-4d8d-abe1-e42cc045d306)

### Accessing the Data Warehouse
With the DAG runs finished, the user can check the warehouse on the port below:
```
https://localhost:8082
```
The default username and password are admin@admin.com and root, respectively.

Then, go to "Server > Register > Server..."

<br>

![image](https://github.com/user-attachments/assets/d9a624bc-b0ad-4e62-ae0a-272ea8105010)

<br>


Now, name the server

<br>

![image](https://github.com/user-attachments/assets/c1b5fda1-74d8-4af9-8afe-a9c6a6a15ede)

<br>


After, under "Connection", use the following parameters to connect to the database, the default password is airflow:

<br>

![image](https://github.com/user-attachments/assets/99198a3d-fe29-4c1c-8c42-e43437b6ae89)

<br>

That's it! The pipeline should be working smoothly now and queries can be made against the warehouse.

## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa

