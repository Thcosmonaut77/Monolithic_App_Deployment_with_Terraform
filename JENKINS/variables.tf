variable "region" {
  description = "region service is provisioned"
  type = string
}

variable "profile" {
  description = "AWS profile"
  type = string
}

variable "my_ip" {
  description = "allowed CIDR"
  type = string
  sensitive = true
}

variable "instance_type" {
  description = "defines the instance type"
  type = string
}

variable "kp" {
  description = "name of key pair"
  type = string
  sensitive = true
}