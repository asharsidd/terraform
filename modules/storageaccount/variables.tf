variable "resource_group_name" {
  type = string
  default = "rg-default-11"
}

variable "resource_group_location" {
  type = string
  default = "eastus"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "instance_count" {
  type    = number
  default = 1
}