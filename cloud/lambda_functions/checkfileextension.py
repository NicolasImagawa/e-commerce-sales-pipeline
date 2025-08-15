import json
import boto3
import urllib.parse

def lambda_handler(event, context):
    s3 = boto3.client("s3")
    lambda_client = boto3.client('lambda')
    
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    try:
        print(f"Attempting to access: s3://{bucket}/{key}")
        if key.endswith('.csv'):
            response_bucket = s3.get_object(Bucket=bucket, Key=key)
            print("CONTENT TYPE: " + response_bucket['ContentType'])
            response_lambda = lambda_client.invoke(
                FunctionName='startStepFunction',
                InvocationType='Event',
                Payload=json.dumps(event)
            )
            return response_bucket['ContentType']
        else:
            print("File is not a csv")
            return False
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
