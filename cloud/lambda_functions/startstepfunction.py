import boto3
import json
import os

def lambda_handler(event, context):
    sfn_client = boto3.client('stepfunctions')
    
    state_machine_arn = os.environ['STATE_MACHINE_ARN']

    response = sfn_client.start_execution(
            stateMachineArn=state_machine_arn,
            input=json.dumps(event)
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Step Function execution started: ' + response['executionArn'])
    }