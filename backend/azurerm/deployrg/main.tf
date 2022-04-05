terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RG-IPT07"
    storage_account_name = "stracct361"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name1
  location = "westus"

  tags = {
    Environment = "Terrform Backend"
    Team        = "Oscar"
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_name2
  location = "eastus"

  tags = {
    Environment = "Terrform Backend"
    Team        = "Alpha"
  }
}