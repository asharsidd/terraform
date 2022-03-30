# Configure the Azure provider
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

locals {
  resource_group = var.resource_group_name
  location = var.location
}

# Deploy two Resource Groups
resource "azurerm_resource_group" "rg" {
  count = 2
  name  = "${local.resource_group}-${count.index+1}"
  location = local.location
  
tags = {
   Environment = "Terrform IAC"
   Team = "CIS"
}
}

