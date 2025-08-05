> [!IMPORTANT]
> The cloud pipeline is still under development.

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

  <img width="1339" height="676" alt="image" src="https://github.com/user-attachments/assets/a04f2560-4d14-4b29-b364-aa4c48d08d84" />

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

Then, under `/home/ec2-user/projects/dbt_files/e_commerce_sales/` run:
```
dbt deps
```

Follow it by:
```
dbt run --profiles-dir "/home/ec2-user/projects/dbt_files/e_commerce_sales" --target dev
```

### Under development
Orchestration;
Applying AWS Glue to the shopee files to avoid duplications;
Creating python scripts for external tables.

## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa


