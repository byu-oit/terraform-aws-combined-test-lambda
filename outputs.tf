output "lambda_function" {
  value = aws_lambda_function.test_lambda
}

output "lambda_iam_role" {
  value = aws_iam_role.test_lambda
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_logs
}
