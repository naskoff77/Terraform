# IAM role to assume lambda
resource "aws_iam_role" "web_s3_contact_lambda_iam_role" {
  name = "${var.env}-web-s3-contact-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
EOF
}

# permission to assume lambda
resource "aws_lambda_permission" "web_s3_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.web_s3_contact_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.web_s3_contact_api_gateway.execution_arn}/*/*"
}

# lambda function which uses code found in primary workload (sent to S3 bucket as a ZIP)
resource "aws_lambda_function" "web_s3_contact_lambda" {
  function_name = "${var.env}-web-s3-contact-lambda"
  role          = aws_iam_role.web_s3_contact_lambda_iam_role.arn

  s3_bucket = aws_s3_bucket.code_bucket.id
  s3_key    = aws_s3_object.code_bucket_lambda_zip.key

  runtime = "python3.9"
  handler = "main.contact_handler"

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      env = var.env
    }
  }
}