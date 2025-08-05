# Overview
This open-source data pipeline shows sales results from Shopee, a major e-commerce platform in Brazil. The results are accomplished through an ELT pipeline using AWS tools that stores data in a AWS Redshift star-schema data warehouse.

The orchestration is still under development

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
  
<img width="1343" height="651" alt="image" src="https://github.com/user-attachments/assets/42f7bb31-97b0-4d28-ac0e-a060f9fd73d6" />


  <br>
  
- Data Warehouse: Redshift serverless;
- Infrastructure: Terraform creates the EC2 instance, the S3 buckets, Redshift namespace and workgroups, while also creating the connection between EC2 and Redshift.
- Extraction: Python to extract the data and transform into .csv file;
- Cleaning: Pandas;
- Loading:
  - Python: when loading the files to AWS S3;
  - dlt, pandas and Python: to load Shopee .csv data after ensuring data types and adding load timestamps;
- Transformation: dbt inside Redshift;
- Orchestration: Under development, not done yet.

## Charts
Still under development.

## Requirements
To run this pipeline, the user needs:
1. A Shopee seller account;
2. A AWS account, root or IAM user, being IAM user recommended for safety reasons.

## Creating IAM roles
This section will show what IAM roles need to be created.

## Running the pipeline

### Configuring and running Terraform
To run the pipeline, first adjust the configurations for each main.tf file. Afterwards, for each of them, run:
```
terraform init
```
Then, please run this command:
```
terraform plan
```
Finally, execute and type "yes":
```
terraform apply
```

### Loading local files to S3
Under elaboration.

### Connect and transfer files to EC2
Inside your local machine user, in path that probably looks like "/home/username/.ssh" or "c:/users/username/.ssh", create a `config` file like this:

```
Host host-name
    HostName 1.234.56.789
    User ec2-user
    IdentityFile c:/users/username/.ssh/ec2-key.pem
```
> [!IMPORTANT]
> Make sure a .pem key value pair exists in AWS that can be used for the SSH connection.

Then, run the command:

```
ssh host-name
```

After connecting to the EC2 instance, transfer the project to EC2.

```
scp -i ~/.ssh/ec2-key.pem -r "c:/users/username/projects/e-commerce-sales-pipeline/cloud/" ec2-user@1.234.56.789:/home/ec2-user/projects
```

> [!TIP]
> If needed, the EC2 instance can be accessed through VSCode via the extension [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)

### Running the rest of the pipeline

Inside the EC2 instance, install:
```
sudo yum install python3-pip -y
pip3 install dlt boto3 psycopg2-binary pandas pyarrow dbt-core dbt-redshift
```
> [!IMPORTANT]
> Make sure that the EC2 instance has IAM roles that include `AmazonS3ReadOnlyAccess` and `AmazonSSMManagedInstanceCore`

Then, preferably inside the path to the loading scripts, run:
```
python3 shopee.py
```

After loading, access Redshift and create the following spectrum schemas and tables:

```
CREATE EXTERNAL SCHEMA spectrum_schema
FROM DATA CATALOG
DATABASE 'spectrum_db'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxx:role/your-IAM'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

CREATE EXTERNAL TABLE spectrum_schema.kit_components (
  main_sku VARCHAR(15),
  product VARCHAR(50),
  sku VARCHAR(15),
  component_sku VARCHAR(15),
  component_name VARCHAR(75) )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://e-commerce-sales-bucket/data/test-spectrum/kit_components/'
TABLE PROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE spectrum_schema.product_sku_cost (
  main_sku VARCHAR(15),
  product VARCHAR(50),
  sku VARCHAR(15),
  component_name VARCHAR(50),
  begin_date TIMESTAMP,
  end_date TIMESTAMP,
  cost NUMERIC(7, 2) )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://e-commerce-sales-bucket/data/test-spectrum/product_sku_cost/'
TABLE PROPERTIES ('skip.header.line.count'='1');
```

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
Then, choose a tag (dev or prod) and run each DAG for the chosen tag on its numerical order after each one of them is finished. This is the UI to be used:

<br>

![image](https://github.com/user-attachments/assets/01c3d8bc-1fa3-4c81-b361-bb3a44bca197)

<br>

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

![image](https://github.com/user-attachments/assets/721c41ed-fdcf-4215-833e-7ef4dabbee5c)

<br>

That's it! The pipeline should be working smoothly now and queries can be made against the warehouse.

### Under development
The partitioning is still under development.
Removing unneeded columns as well.

## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa


