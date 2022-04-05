# This script will deploy a complete VM with NSG, a new Data Disk and will Install IIS using a PS script

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
  resource_group = var.rg_name
  location       = var.location
}


resource "azurerm_resource_group" "rg" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_virtual_network" "rg_vnet" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.rg_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.rg_vnet
  ]
}

resource "azurerm_network_interface" "rg_interface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.rg_pip.id
  }

  depends_on = [
    azurerm_virtual_network.rg_vnet,
    azurerm_public_ip.rg_pip,
    azurerm_subnet.SubnetA
  ]
}

resource "azurerm_windows_virtual_machine" "rg_vm" {
  name                = var.vmname
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_DS2_v2"
  admin_username      = var.username
  admin_password      = var.password
  availability_set_id = azurerm_availability_set.rg_avset.id
  network_interface_ids = [
    azurerm_network_interface.rg_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.rg_interface,
    azurerm_availability_set.rg_avset
  ]
}

resource "azurerm_public_ip" "rg_pip" {
  name                = "${var.vmname}_pip"
  resource_group_name = local.resource_group
  location            = local.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "${var.vmname}_datadisk"
  location             = local.location
  resource_group_name  = local.resource_group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16
  depends_on = [
    azurerm_resource_group.rg
  ]
}
# attach the data disk to the Azure virtual machine

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.rg_vm.id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on = [
    azurerm_windows_virtual_machine.rg_vm,
    azurerm_managed_disk.data_disk
  ]
}

resource "azurerm_availability_set" "rg_avset" {
  name                         = "${var.vmname}_avset"
  location                     = local.location
  resource_group_name          = local.resource_group
  platform_fault_domain_count  = 2
  platform_update_domain_count = 3
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_storage_account" "stracct" {
  name                     = "stracct361"
  resource_group_name      = local.resource_group
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "stracct361"
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.stracct
  ]
}

# Here we are uploading our IIS Configuration script as a blob
# to the Azure storage account

resource "azurerm_storage_blob" "IIS_config" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = "stracct361"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
  depends_on             = [azurerm_storage_container.data]
}

resource "azurerm_virtual_machine_extension" "vm_extension" {
  name                 = "${var.vmname}_extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.rg_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IIS_config
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.stracct.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS

}

resource "azurerm_network_security_group" "rg_nsg" {
  name                = "${var.vmname}_nsg"
  location            = local.location
  resource_group_name = local.resource_group
  depends_on = [
    azurerm_resource_group.rg
  ]
}


resource "azurerm_network_security_rule" "rg_nsgrule" {
  for_each                    = local.nsgrules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rg_nsg.name
  depends_on = [
    azurerm_network_security_group.rg_nsg
  ]
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.rg_nsg.id
  depends_on = [
    azurerm_network_security_group.rg_nsg
  ]
}

data "azurerm_public_ip" "rg_pip" {
  name                = "${var.vmname}_pip"
  resource_group_name = var.rg_name
}
output "public_ip_address" {
  value = data.azurerm_public_ip.rg_pip.ip_address
}