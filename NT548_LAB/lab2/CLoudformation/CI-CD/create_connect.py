import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('codestar-connections')

    try:
        # Create GitHub connection
        response = client.create_connection(
            ProviderType='GitHub',
            ConnectionName='MyGitHubConnection'  # Optional: Give a custom name
        )

        # Send the response back to CloudFormation
        physical_resource_id = response['ConnectionArn']
        return {
            'Status': 'SUCCESS',
            'PhysicalResourceId': physical_resource_id,
            'Data': {'ConnectionArn': physical_resource_id}
        }

    except Exception as e:
        return {
            'Status': 'FAILED',
            'Reason': str(e),
            'PhysicalResourceId': 'MyGitHubConnection'
        }
