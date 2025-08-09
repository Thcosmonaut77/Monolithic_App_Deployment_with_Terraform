variable "profile" {
  description = "AWS profile"
  type = string
}

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
  sensitive = true
}

variable "script_user" {
  description = "Script username"
  type = string
}

variable "script_password" {
  description = "Script user password"
  type = string
  sensitive = true
}

variable "gui_user" {
  description = "GUI username"
  type = string
}

variable "gui_password" {
  description = "GUI user password"
  type = string
  sensitive = true
}