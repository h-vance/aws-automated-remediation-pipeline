variable "remediation_lambda_arn" {
  description = "The ARN of the Lambda function that executes the remediation."
  type        = string
}

variable "alerts_topic_arn" {
  description = "The ARN of the SNS topic for notifications."
  type        = string
}
