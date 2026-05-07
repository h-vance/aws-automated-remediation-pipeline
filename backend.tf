# Terraform remote state backend configuration
# This should be updated after creating the S3 bucket and DynamoDB table.
terraform {
  # backend "s3" {
  #   bucket         = "h-vance-tf-state"
  #   key            = "aws-remediation/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
