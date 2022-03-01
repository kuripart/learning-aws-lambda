# https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway?in=terraform/aws

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"
}


## Hosting code in ECR --------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "lambda" {
  name                 = "test"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "Test"
  package_type =  "Image" # required for ecr images
  image_uri = "${aws_ecr_repository.lambda.repository_url}:latest"

  runtime = "python3.8"
  handler = "test.lambda_handler"

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"

  retention_in_days = 1
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


## Hosting code in S3 --------------------------------------------------------------------------------------------------------------------------------------------------

# resource "random_pet" "lambda_bucket_name" {
#   prefix = "learn-terraform-functions"
#   length = 4
# }


# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket = random_pet.lambda_bucket_name.id
# }

# data "archive_file" "lambda_function" {
#   type = "zip"

#   source_dir  = "${path.module}/test"
#   output_path = "${path.module}/test.zip"
# }

# resource "aws_s3_object" "lambda_function" {
#   bucket = aws_s3_bucket.lambda_bucket.id

#   key    = "test.zip"
#   source = data.archive_file.lambda_function.output_path

#   etag = filemd5(data.archive_file.lambda_function.output_path)
# }


# resource "aws_lambda_function" "lambda_function" {
#   function_name = "Test"

#   s3_bucket = aws_s3_bucket.lambda_bucket.id
#   s3_key    = aws_s3_object.lambda_function.key

#   runtime = "python3.8"
#   handler = "test.lambda_handler"

#   source_code_hash = data.archive_file.lambda_function.output_base64sha256

#   role = aws_iam_role.lambda_exec.arn
# }

# resource "aws_cloudwatch_log_group" "hello_world" {
#   name = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"

#   retention_in_days = 1
# }

# resource "aws_iam_role" "lambda_exec" {
#   name = "serverless_lambda"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Sid    = ""
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }


# resource "aws_cloudwatch_log_group" "api_gw" {
#   name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

#   retention_in_days = 1
# }


# resource "aws_apigatewayv2_api" "lambda" {
#   name          = "serverless_lambda_gw"
#   protocol_type = "HTTP"
# }


# resource "aws_apigatewayv2_stage" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   name        = "serverless_lambda_stage"
#   auto_deploy = true

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_gw.arn

#     # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html#set-up-access-logging-permissions
#     format = jsonencode({
#       requestId               = "$context.requestId"
#       sourceIp                = "$context.identity.sourceIp"
#       requestTime             = "$context.requestTime"
#       protocol                = "$context.protocol"
#       httpMethod              = "$context.httpMethod"
#       resourcePath            = "$context.resourcePath"
#       routeKey                = "$context.routeKey"
#       status                  = "$context.status"
#       responseLength          = "$context.responseLength"
#       integrationErrorMessage = "$context.integrationErrorMessage"
#       }
#     )
#   }
# }

# # configures the API Gateway to use your Lambda function.
# resource "aws_apigatewayv2_integration" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   integration_uri    = aws_lambda_function.lambda_function.invoke_arn
#   integration_type   = "AWS_PROXY"
#   integration_method = "POST"
# }

# # maps an HTTP request to a target, in this case your Lambda function.
# resource "aws_apigatewayv2_route" "lambda" {
#   api_id = aws_apigatewayv2_api.lambda.id

#   route_key = "GET /test"
#   target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
# }

# resource "aws_lambda_permission" "api_gw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda_function.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
# }