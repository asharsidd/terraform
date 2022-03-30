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
  resource_group = "mod-rg"
  location = "westus"
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = local.resource_group
  location = local.location
}

# all properties will be fetched from Module
module "storageaccount" {
  source = "../modules/storageaccount"

  resource_group_name     = azurerm_resource_group.resourcegroup.name
  resource_group_location = azurerm_resource_group.resourcegroup.location
}
