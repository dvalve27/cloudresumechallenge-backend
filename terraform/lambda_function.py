import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    response = table.update_item(
        Key={'id': 'counter'},
        UpdateExpression='ADD hits :inc',
        ExpressionAttributeValues={':inc': 1},
        ReturnValues="UPDATED_NEW"
    )
    
    hits = str(response['Attributes']['hits'])
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*', # Or your specific domain
            'Access-Control-Allow-Methods': 'POST,OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps({'hits': hits})
    }