variable "username" {
  description = "Username for the VM"
  type        = string
  default     = "asharsidd"
}

variable "password" {
  description = "Password for the VM"
  type        = string
  sensitive   = true
}

variable "vmname" {
  description = "Name of the VM"
  type        = string
  default     = "matrix601"
}

variable "rg_name" {
  description = " Resource Group name"
  type        = string
  default     = "RG-IPT07"
}

variable "location" {
  description = "Location of the VM"
  type        = string
  default     = "eastus"
}