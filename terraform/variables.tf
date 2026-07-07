variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-0fd4178177aeeb9e8"
}

variable "subnet_id" {
  default = "subnet-0dd6b6963f3b63b0e"
}

variable "key_name" {
  default = "py-bite"
}

variable "admin_ip" {
  description = "Your home IP for SSH and dashboard access (x.x.x.x/32)"
  type        = string
}

variable "honeypot_private_ip" {
  description = "Private IP of existing t3.micro honeypot"
  default     = "172.31.40.82"
}

variable "instance_type" {
  # t3.medium isn't on this account's free-tier-eligible instance whitelist —
  # confirmed 2026-07-07 via a real failed apply (InvalidParameterCombination).
  # c7i-flex.large (4GB/2vCPU) is the smallest allowed type that meets Wazuh's
  # actual minimum spec — deliberately not m7i-flex.large, which is on the
  # whitelist too but is the exact instance type that caused the original
  # cost-drift teardown.
  default = "c7i-flex.large"
}
