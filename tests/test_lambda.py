import json
import sys
import os
import boto3
import pytest
from moto import mock_aws

@pytest.fixture
def aws_credentials():
    """Mocked AWS Credentials for moto."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_SECURITY_TOKEN"] = "testing"
    os.environ["AWS_SESSION_TOKEN"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"
    os.environ["TABLE_NAME"] = "test-site-hits"

@pytest.fixture
def dynamodb_table(aws_credentials):
    """Creates a mock DynamoDB table for testing."""
    with mock_aws():
        db = boto3.resource("dynamodb", region_name="us-east-1")
        table = db.create_table(
            TableName=os.environ["TABLE_NAME"],
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode='PAY_PER_REQUEST'
        )
        # Initialize the counter item
        table.put_item(Item={"id": "counter", "hits": 0})
        yield table


def test_lambda_handler_updates_counter(dynamodb_table):
    """Test if the lambda correctly increments the hits in DynamoDB."""
    from terraform.lambda_function import lambda_handler  # Import here to delay execution
    event = {}
    context = {}

    # Call the lambda handler
    response = lambda_handler(event, context)

    # Parse the body
    body = json.loads(response["body"])

    # Assertions
    assert response["statusCode"] == 200
    assert body["hits"] == "1"
    assert "Access-Control-Allow-Origin" in response["headers"]


def test_lambda_handler_increments_multiple_times(dynamodb_table):
    """Test if multiple calls continue to increment the same counter."""
    from terraform.lambda_function import lambda_handler  # Import here to delay execution
    event = {}
    context = {}

    # Call twice
    lambda_handler(event, context)
    response = lambda_handler(event, context)

    body = json.loads(response["body"])

    assert body["hits"] == "2"