resource "aws_iam_role" "iam_for_lambda" {
  name = "counter_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Permission for Lambda to talk to DynamoDB
resource "aws_iam_role_policy" "dynamodb_lambda_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
      Effect   = "Allow"
      Resource = aws_dynamodb_table.site_counter.arn
    }]
  })
}

resource "aws_lambda_function" "counter_handler" {
  # Reference the output_path from the data source
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "SiteCounterHandler"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  # This ensures the function updates when your Python code changes
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.site_counter.name
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}