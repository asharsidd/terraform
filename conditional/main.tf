# Creating two storage accounts for dev and prod based on condition if it is true or false 
# for true will create in dev and for false create in Prod


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

resource "random_string" "rand" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "dev" {
  count = var.flag == true ? 1 : 0

  name                      = "${random_string.rand.id}str361"
  resource_group_name       = var.resource_group_name
  location                  = "eastus"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false

  tags = {
    environment = var.environment[0]
  }
}

resource "azurerm_storage_account" "prod" {
  count = var.flag == true ? 0 : 1

  name                      = "${random_string.rand.id}str461"
  resource_group_name       = var.resource_group_name
  location                  = "westus"
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false

  tags = {
    environment = var.environment[1]
  }
}