locals {
str_name = format("vob%s00", var.environment)
}

resource "azurerm_storage_account" "storageaccount" {
  count = var.instance_count

  name                      = "${local.str_name}${count.index + 1}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  allow_blob_public_access  = false

  tags = {
    environment = var.environment
  }
}