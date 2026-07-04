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
  default = "t3.small"
}
