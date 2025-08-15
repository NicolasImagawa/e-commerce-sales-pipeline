> [!IMPORTANT]
> The cloud pipeline is still under development.

# Overview
This open-source data pipeline shows sales results from Shopee, a major e-commerce platform in Brazil. The results are accomplished through an ELT pipeline using AWS tools that stores data in a AWS Redshift star-schema data warehouse.

The orchestration is still under development

## Contents
- [Tools and technologies used for the pipeline development](#tools-and-technologies-used-for-the-pipeline-development)
- [Charts](#charts)
- [Requirements](#requirements)
- [Creating IAM roles](#creating-iam-roles)
- [Running the pipeline](#running-the-pipeline)
  - [Configuring and running Terraform](#configuring-and-running-terraform)
  - [Loading local files to S3](#loading-local-files-to-s3)
  - [Connect and transfer files to EC2](#connect-and-transfer-files-to-ec2)
  - [Running the rest of the pipeline](#running-the-rest-of-the-pipeline)
  - [Under development](#under-development)
- [Contact](#contact)
  
## Tools and technologies used for the pipeline development
The following picture shows how the pipeline works end-to-end.
  
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

## Details about the orchestration
Below, one can see the workflow for the AWS Step Function usage in this pipeline.

<br>

<img width="1466" height="1674" alt="stepfunctions_graph" src="https://github.com/user-attachments/assets/0d3037e0-e2bc-4e82-aef3-de6120f730a9" />

<br>

The workflow follows these procedures in its orchestration: sends a command to the EC2 instance, then waits a few seconds, checks the command status via SSM, the evaluates if it goes to the next command in the VM.

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
To run the pipeline, first adjust the configurations for the main.tf file by creating variables.tf. Afterwards, run:
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
Terraform already loads the needed files to the EC2 instance, but this section helps you to load extra files using SCP.

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

After connecting to the EC2 instance, transfer any additional files that you might need to EC2.

```
scp -i ~/.ssh/ec2-key.pem -r "c:/users/username/projects/e-commerce-sales-pipeline/cloud/your-file" ec2-user@1.234.56.789:/home/ec2-user/path/to/file
```

> [!TIP]
> If needed, the EC2 instance can be accessed through VSCode via the extension [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)


### Under development
AWS Glue PySpark jobs - the code can be found [here](https://github.com/NicolasImagawa/e-commerce-sales-pipeline/blob/feature/cloud/cloud/scripts/pyspark/cluster.py)
Managing queues for multiple files loaded at once, probably with AWS SQS;
Improve external table management and loading to the Warehouse.


## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa


