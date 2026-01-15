variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "pow-faucet-node"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "pow-faucet-vpc"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}