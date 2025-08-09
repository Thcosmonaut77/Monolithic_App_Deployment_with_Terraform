variable "region" {
    description = "AWS region"
    type = string
  
}

variable "my_ip" {
    description = "allowed CIDR"
    type = string
    sensitive = true
  
}

variable "instance_type" {
  description = "instance type"
  type = string
}

variable "kp" {
  description = "key pair name"
  type = string
}

variable "profile" {
  description = "AWS profile"
  type = string
}