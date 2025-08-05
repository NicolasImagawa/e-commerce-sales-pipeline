import logging
import boto3
from botocore.exceptions import ClientError
import os

from config.config import PATHS

bucket = PATHS["bucket"]

ingestion_paths_dev = [
    {
        'local': PATHS['load_data_shopee']['dev']['local_dir'],
        'cloud': PATHS['load_data_shopee']['dev']['path'],
        'source': 'shopee'
    },

    {
        'local': PATHS['load_kits']['dev']['local_dir'],
        'cloud': PATHS['load_kits']['dev']['path'],
        'source': 'user'
    },

    {
        'local': PATHS['load_prices']['dev']['local_dir'],
        'cloud': PATHS['load_prices']['dev']['path'],
        'source': 'user'
    }
]

ingestion_paths_prod = [
    {
        'local': PATHS['load_data_shopee']['prod']['local_dir'],
        'cloud': PATHS['load_data_shopee']['prod']['path'],
        'source': 'shopee'
    },

    {
        'local': PATHS['load_kits']['prod']['local_dir'],
        'cloud': PATHS['load_kits']['prod']['path'],
        'source': 'user'
    },

    {
        'local': PATHS['load_prices']['prod']['local_dir'],
        'cloud': PATHS['load_prices']['prod']['path'],
        'source': 'user'
    }
]

def upload_file(file_name, bucket, key, object_name=None):
    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = os.path.basename(file_name)

    # Upload the file
    s3_client = boto3.client('s3')
    try:
        response = s3_client.upload_file(file_name, bucket, key)
        print(f"Data successfully ingested to {bucket}{key}")
    except ClientError as e:
        logging.error(e)
        return False
    return True

def read_paths(env: bool) -> None:
    if env == 'dev':
        ingestion_paths = ingestion_paths_dev
    elif env == 'prod':
        ingestion_paths = ingestion_paths_prod
    else:
        print(f"Environment {env} could not be found.")
        return
    
    for paths in ingestion_paths:
        print(paths)
        if paths['source'] == 'shopee':
            filelist = os.listdir(paths['local'])
            files = [f"{paths['local']}/{file}" for file in filelist]

            for file in files:
                key = f"{paths['cloud']}{os.path.basename(file)}"
                upload_file(file, bucket, key)
        else:
            file = paths['local']
            key = paths['cloud']
            upload_file(file, bucket, key)

read_paths(env = 'dev')