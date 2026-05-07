variable "state_machine_arn" {
  description = "The ARN of the Step Functions state machine to trigger."
  type        = string
}

variable "test_instance_id" {
  description = "A test instance ID to associate with the CloudWatch Alarm."
  type        = string
  default     = "i-placeholder"
}
