variable "app_name" {
  type        = string
  description = "Application name to name your postman test lambda function"
}

variable "role_permissions_boundary_arn" {
  type        = string
  description = "ARN of the IAM Role permissions boundary to place on each IAM role created."
}

variable "log_retention_in_days" {
  type        = number
  description = "CloudWatch log group retention in days. Defaults to 7."
  default     = 7
}

variable "tags" {
  type        = map(string)
  description = "A map of AWS Tags to attach to each resource created"
  default     = {}
}

variable "memory_size" {
  type        = number
  description = "The size of memory for the lambda"
  default     = 256
}

variable "timeout" {
  type        = number
  description = "The amount of time the lambda is allowed to run for"
  default     = 600
}

variable "postman_test_lambda_arn" {
  type        = string
  description = "ARN of the postman test lambda to call"
}

variable "ui_test_lambda_arn" {
  type        = string
  description = "ARN of the UI test lambda to cell"
}
