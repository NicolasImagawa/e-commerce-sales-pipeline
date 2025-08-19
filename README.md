# Overview
This open-source data pipeline shows sales results from two major e-commerce platforms in Brazil (Mercado Livre and Shopee) and can be used both as on-premises or with cloud tools.
For more details, please check one of them below:
- [Local](https://github.com/NicolasImagawa/e-commerce-sales-pipeline/tree/feature/cloud/local);
- [Cloud](https://github.com/NicolasImagawa/e-commerce-sales-pipeline/tree/feature/cloud/cloud).

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
The following picture shows how the pipeline works end-to-end in the local environment
  
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


Regarding the cloud environment, the following picture shows how the pipeline works end-to-end.
  
  <br>

<img width="1283" height="481" alt="image" src="https://github.com/user-attachments/assets/7ea57134-5a6c-4932-b76a-ac859d72833f" />

  <br>
  
- Data Warehouse: Redshift serverless;
- Infrastructure: Terraform creates the EC2 instance, the S3 buckets, Redshift namespace and workgroups, while also creating the connection between EC2 and Redshift.
- Extraction: Python to extract the data and transform into .csv file;
- Cleaning: Pandas;
- Loading:
  - The loading phase is divided in two steps: First, the data is transformed and has its files converted to parquet to a staging bucket. Then, this bucket becomes the external table for the database to avoid duplicates.
- Transformation: dbt inside Redshift;
- Orchestration: Done with AWS Step Functions.

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

## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa

