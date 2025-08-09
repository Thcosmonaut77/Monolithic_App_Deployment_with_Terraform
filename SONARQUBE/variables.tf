variable "region" {
  description = "AWS region"
  type = string
}

variable "profile" {
  description = "AWS profile"
  type = string
}

variable "my_ip" {
  description = "allowed CIDR"
  type = string
}

variable "user" {
  description = "sonarqube username"
  type = string
}

variable "password" {
  description = "sonarqube user password"
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