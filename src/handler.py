import boto3
import json
import os


def lambda_handler(event, context):

    codedeploy_client = boto3.client('codedeploy')
    lambda_client = boto3.client('lambda')
    deployment_id = event['DeploymentId']
    lifecycle_event_hook_execution_id = event['LifecycleEventHookExecutionId']

    input_parameters = {
        'Combined': True
    }

    postman_response = lambda_client.invoke(
        FunctionName=os.environ['POSTMAN_LAMBDA_NAME'],
        InvocationType='RequestResponse',
        Payload=json.dumps(input_parameters)
    )

    ui_response = lambda_client.invoke(
        FunctionName=os.environ['UI_LAMBDA_NAME'],
        InvocationType='RequestResponse',
        Payload=json.dumps(input_parameters)
    )
    
    # codedeploy_client.put_lifecycle_event_hook_execution_status(
    #     deploymentId=deployment_id,
    #     lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
    #     status='Succeeded'
    # )
