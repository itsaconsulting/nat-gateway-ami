variable "instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to build in."
}
