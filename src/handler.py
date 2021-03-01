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

    print('Beginning Postman Tests')

    postman_lambda_response = lambda_client.invoke(
        FunctionName=os.environ['POSTMAN_LAMBDA_NAME'],
        InvocationType='RequestResponse',
        Payload=json.dumps(input_parameters)
    )
    postman_response = json.load(postman_lambda_response['Payload'])
    if postman_response['passed']:
        print('Postman tests passed. Beginning UI tests')
    else:
        codedeploy_client.put_lifecycle_event_hook_execution_status(
            deploymentId=deployment_id,
            lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
            status='Failed'
        )
        raise Exception('Postman tests failed')

    ui_lambda_response = lambda_client.invoke(
        FunctionName=os.environ['UI_LAMBDA_NAME'],
        InvocationType='RequestResponse',
        Payload=json.dumps(input_parameters)
    )
    ui_response = json.load(ui_lambda_response['Payload'])
    if ui_response['passed']:
        print('UI tests successfully ran')
    else:
        codedeploy_client.put_lifecycle_event_hook_execution_status(
            deploymentId=deployment_id,
            lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
            status='Failed'
        )
        raise Exception('UI test failed')

    codedeploy_client.put_lifecycle_event_hook_execution_status(
        deploymentId=deployment_id,
        lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
        status='Succeeded'
    )
