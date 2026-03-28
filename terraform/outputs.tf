output "api_gateway_url" {
  value = aws_apigatewayv2_api.counter_api.api_endpoint
}

output "website_custom_domain_url" {
  value = "https://${var.domain_name}"
}