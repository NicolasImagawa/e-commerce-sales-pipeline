FROM apache/airflow:2.10.4-python3.9

USER root

RUN apt-get update && apt-get install -y wget unzip && \
    wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip && \
    unzip terraform_1.10.5_linux_amd64.zip -d /usr/local/bin && \
    rm terraform_1.10.5_linux_amd64.zip

USER airflow

RUN terraform --version

COPY requirements.txt /requirements.txt

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r /requirements.txt
