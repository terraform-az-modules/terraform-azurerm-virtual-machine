provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.0"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.0"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

# ------------------------------------------------------------------------------
# Subnet
# ------------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azure"
  version              = "1.0.0"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
}

#-----------------------------------------------------------------------------
# Network Security Group
#-----------------------------------------------------------------------------
module "security_group" {
  source              = "terraform-az-modules/nsg/azure"
  version             = "1.0.0"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location

  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "0.0.0.0/0"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    }
  ]
}

#-----------------------------------------------------------------------------
# Key Vault
#-----------------------------------------------------------------------------
module "key_vault" {
  source                        = "terraform-az-modules/key-vault/azure"
  version                       = "1.0.0"
  name                          = "core"
  environment                   = "dev"
  label_order                   = ["name", "environment", "location"]
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  sku_name                      = "premium"
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  private_dns_zone_ids = module.private_dns_zone.private_dns_zone_ids.key_vault
}

# ------------------------------------------------------------------------------
# Private DNS Zone
# ------------------------------------------------------------------------------
module "private_dns_zone" {
  source              = "terraform-az-modules/private-dns/azure"
  version             = "1.0.0"
  name                = "dns"
  environment         = "dev"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  private_dns_config = [
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

#-----------------------------------------------------------------------------
# Log Analytics
#-----------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azure"
  version                     = "1.0.0"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

#-----------------------------------------------------------------------------
# Linux Virtual Machine
#-----------------------------------------------------------------------------
module "virtual-machine" {
  source              = "../../"
  depends_on          = [module.key_vault]
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  key_vault_id        = module.key_vault.id
  is_vm_linux         = true
  user_object_id = {
    "user1" = {
      role_definition_name = "Virtual Machine Administrator Login"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  subnet_id                 = module.subnet.subnet_ids.subnet1
  private_ip_addresses      = ["10.0.1.8"]
  network_security_group_id = module.security_group.id
  vm_size                   = "Standard_B1s"
  admin_username            = "ubuntu"
  public_key                = "ssh-rsa AAA"
  caching                   = "ReadWrite"
  disk_size_gb              = 30
  image_publisher           = "Canonical"
  image_offer               = "0001-com-ubuntu-server-jammy"
  image_sku                 = "22_04-lts-gen2"
  image_version             = "latest"
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 60
      storage_account_type = "StandardSSD_LRS"
    }
  ]
  extensions = [
    {
      extension_publisher            = "Microsoft.Azure.ActiveDirectory"
      extension_name                 = "AADLogin"
      extension_type                 = "AADSSHLoginForLinux"
      extension_type_handler_version = "1.0"
      auto_upgrade_minor_version     = true
      automatic_upgrade_enabled      = false
    }
  ]
  log_analytics_workspace_id = module.log-analytics.workspace_id
  user_data                  = base64encode(file("user-data.sh"))
}
