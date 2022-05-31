# API gateway for contact form
resource "aws_api_gateway_rest_api" "web_s3_contact_api_gateway" {
  name = "${var.env}-web-s3-api-gateway"
}

# API gateway resource for contact form
resource "aws_api_gateway_resource" "web_s3_contact_api_gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.web_s3_contact_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.web_s3_contact_api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

# API method to receive REST calls from the form
resource "aws_api_gateway_method" "web_s3_contact_gateway_method" {
  rest_api_id      = aws_api_gateway_rest_api.web_s3_contact_api_gateway.id
  resource_id      = aws_api_gateway_resource.web_s3_contact_api_gateway_resource.id
  http_method      = "POST"
  authorization    = "AWS_IAM"
  api_key_required = true
}

# API gateway lambda integration
resource "aws_api_gateway_integration" "web_s3_contact_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.web_s3_contact_api_gateway.id
  resource_id = aws_api_gateway_resource.web_s3_contact_api_gateway_resource.id
  http_method = aws_api_gateway_method.web_s3_contact_gateway_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.web_s3_contact_lambda.invoke_arn
}