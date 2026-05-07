provider "aws" {
  region = "us-east-1"
}

# Fetch default VPC for the remediation module
data "aws_vpc" "default" {
  default = true
}

module "global_infra" {
  source = "../../modules/global"

  state_bucket_name = "h-vance-remediation-tf-state"
  lock_table_name   = "h-vance-remediation-tf-locks"
}

module "remediation" {
  source = "../../modules/terraform-aws-remediation-core"
  vpc_id = data.aws_vpc.default.id
}

module "notification" {
  source = "../../modules/terraform-aws-notification-engine"
}

output "github_role_arn" {
  value = module.global_infra.github_actions_role_arn
}

output "remediation_lambda_name" {
  value = module.remediation.remediation_lambda_name
}

output "alerts_topic_arn" {
  value = module.notification.alerts_topic_arn
}
