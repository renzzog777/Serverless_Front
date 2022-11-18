terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-west-2"
}




resource "aws_dynamodb_table" "ddbtable" {
  name             = "myTable"
  hash_key         = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "id"
    type = "S"
  }
}


resource "aws_iam_role_policy" "write_policy" {
  name = "lambda_write_policy"
  role = aws_iam_role.writeRole.id

  policy = file("./writeRole/write_policy.json")
}


resource "aws_iam_role_policy" "read_policy" {
  name = "lambda_read_policy"
  role = aws_iam_role.readRole.id

  policy = file("./readRole/read_policy.json")
}


resource "aws_iam_role" "writeRole" {
  name = "myWriteRole"

  assume_role_policy = file("./writeRole/assume_write_role_policy.json")
}


resource "aws_iam_role" "readRole" {
  name = "myReadRole"

  assume_role_policy = file("./readRole/assume_read_role_policy.json")

}

data "archive_file" "zipread" {
 type        = "zip"
 source_file  = "${path.module}/readterra.js"
 output_path = "${path.module}/readterra.zip"
}

data "archive_file" "zip2" {
 type        = "zip"
 source_file  = "${path.module}/writeterra.js"
 output_path = "${path.module}/writeterra.zip"
}


resource "aws_lambda_function" "writeLambda" {

  function_name = "writeLambda"
  filename      = "${path.module}/writeterra.zip"
  role          = aws_iam_role.writeRole.arn
  handler       = "writeterra.handler"
  runtime       = "nodejs12.x"


}

resource "aws_lambda_function" "readLambda" {

  function_name = "readLambda"
  filename      = "${path.module}/readterra.zip"
  role          = aws_iam_role.readRole.arn
  handler       = "readterra.handler"
  runtime       = "nodejs12.x"

}



resource "aws_apigatewayv2_api" "apiLambda" {
  name          = "myAPI"
  protocol_type = "HTTP"

cors_configuration {
    allow_origins = ["http://*", "https://*"]
    allow_headers = ["*"]
    allow_methods = ["*"]

}
}


resource "aws_apigatewayv2_integration" "read_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Read"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.readLambda.arn
}

resource "aws_apigatewayv2_integration" "write_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "Write"
  integration_method     = "POST"
  payload_format_version = "2.0"
  integration_uri        = aws_lambda_function.writeLambda.arn
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "Api deployment"


  lifecycle {
    create_before_destroy = true
  }

}


#test 1
