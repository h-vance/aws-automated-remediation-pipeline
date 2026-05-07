variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "The name of the DynamoDB table for state locking."
  type        = string
}
