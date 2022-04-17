terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


variable "region" {
  type        = string
  description = "Region in Azure"
  default     = "eastus"
}

variable "prefix" {
  type        = string
  description = "prefix for naming"
  default     = "nazimkar"
}


locals {
  name = "${var.prefix}-777"
}

resource "azurerm_resource_group" "vnet" {
  name     = local.name
  location = var.region
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "3.1.1"
  resource_group_name = azurerm_resource_group.vnet.name
  vnet_name           = "${local.name}-vnet"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnetX", "subnetY", "subnetZ"]

  tags = {
    environment = "uat"
    team = "IT"

  }

  depends_on = [azurerm_resource_group.vnet]
}