terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = "~>1.1.0"
}

provider "azurerm" {
  features {

    virtual_machine {
      skip_shutdown_and_force_delete = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  alias           = "prodwestus"
}


resource "azurerm_resource_group" "rg" {
  name     = "Rg777"
  location = "EastUS"
}

resource "azurerm_resource_group" "rg1" {
  name     = "Rg666"
  location = "West US"
  provider = azurerm.prodwestus

}