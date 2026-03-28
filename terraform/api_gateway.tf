resource "aws_apigatewayv2_api" "counter_api" {
  name          = "SiteCounterAPI"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["https://${var.domain_name}"] # Restrict to your domain
    allow_methods = ["GET", "POST"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_int" {
  api_id           = aws_apigatewayv2_api.counter_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.counter_handler.invoke_arn
}

resource "aws_apigatewayv2_route" "counter_route" {
  api_id    = aws_apigatewayv2_api.counter_api.id
  route_key = "POST /increment"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_int.id}"
}

resource "aws_lambda_permission" "api_gw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.counter_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.counter_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_url" {
  value = aws_apigatewayv2_api.counter_api.api_endpoint
}