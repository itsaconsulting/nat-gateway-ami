variable "instance_type" {
  type        = string
  default     = "t4g.nano"
  description = "The instance type to use."
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region to build the AMI in."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to build in."
}
