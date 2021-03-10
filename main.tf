terraform {
  required_version = ">= 0.12.16"
  required_providers {
    aws = ">= 3.0.0"
  }
}

# -----------------------------------------------------------------------------
# START OF LAMBDA FUNCTION
# -----------------------------------------------------------------------------
resource "aws_lambda_function" "test_lambda" {
  filename         = "${path.module}/lambda/dist/sourceCode.zip"
  function_name    = "${var.app_name}-combined-tests"
  role             = aws_iam_role.test_lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.8"
  timeout          = var.timeout
  memory_size      = var.memory_size
  source_code_hash = base64sha256("${path.module}/lambda/dist/function.zip")
  environment {
    variables = {
      "POSTMAN_LAMBDA_ARN" = var.postman_test_lambda_arn
      "UI_LAMBDA_ARN"      = var.ui_test_lambda_arn
    }
  }
  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

resource "aws_iam_role" "test_lambda" {
  name                 = "${var.app_name}-combined-tests"
  permissions_boundary = var.role_permissions_boundary_arn
  tags                 = var.tags

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

resource "aws_iam_role_policy" "test_lambda" {
  name = "${var.app_name}-combined-tests"
  role = aws_iam_role.test_lambda.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": "codedeploy:PutLifecycleEventHookExecutionStatus",
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${var.postman_test_lambda_arn}",
        "${var.ui_test_lambda_arn}"
      ]
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.app_name}-combined-tests"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
# -----------------------------------------------------------------------------
# END OF LAMBDA FUNCTION
# -----------------------------------------------------------------------------
