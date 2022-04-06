variable "resource_group_name" {
  type    = string
  default = "RG361"
}

variable "environment" {
  type    = list(any)
  default = ["dev", "prod"]
}

variable "flag" {
  type = bool
}