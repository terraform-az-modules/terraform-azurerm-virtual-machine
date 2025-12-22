provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
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
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
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
  source              = "terraform-az-modules/nsg/azurerm"
  version             = "1.0.1"
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
      source_address_prefix      = "10.0.0.0/16"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "SSH from VNet to internet"
    }
  ]
}

#-----------------------------------------------------------------------------
# Log Analytics
#-----------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "1.0.2"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
}

#-----------------------------------------------------------------------------
# Key Vault
#-----------------------------------------------------------------------------
module "key_vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.0.1"
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
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.2"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
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
# Linux Virtual Machine
#-----------------------------------------------------------------------------
module "virtual-machine" {
  source              = "../../"
  depends_on          = [module.key_vault]
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  backup_enabled      = true
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  is_vm_linux         = true
  key_vault_id        = module.key_vault.id
  user_object_id = {
    "user1" = {
      role_definition_name = "Virtual Machine Administrator Login"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  backup_policy_retention = {
    daily = {
      enabled   = true
      frequency = "Daily"
      count     = "30"
      weekdays  = []
      weeks     = []
    }
    weekly = {
      enabled = false
    }
    monthly = {
      enabled = false
    }
  }
  subnet_id                 = module.subnet.subnet_ids.subnet1
  private_ip_addresses      = ["10.0.1.9"]
  network_security_group_id = module.security_group.id
  vm_size                   = "Standard_B1s"
  admin_username            = "ubuntu"
  public_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrLYo7b+IBzOLRJtxS+PTZxLFojNS6fHzGm6a1Ldzo/NHccHo9Dnd1TOesoCiK5VytgutPUKbZ+7kvz0v1MbKWQhP6f4XuQi/Acq14TJIQ5HFl1lk9S0v0HsrAzWKr4hSnGI+FmYO+/sFy/swlV4TNEAfNqJDlD7SEeuiKFtx58u04Sctvr3X1hJ6ZXmAv/9/AYbhyPIP91Bu38ANwThqahHz7SuD7vyhT1986WnxYplAyqH21rJo59BXlcaoFtsP6VZ7+IkIZCp9KERolvi/Uq8pP48HCYjT3JRPMAc+9lGJHGmcdJwFmZgDLZvcEGfqu/hPCwXCAeRFjqgq6gT/mUJoxHU96ifkFA+tuF2n3h6gOZsk3oUpUqVTWVBySJ0m0yTyo8U9sjsA83QxR8oEwHT7EmKKVkiHah2WCi0/U7yS9i64LQd+PxdJ8vCGei/mbX3vZjdz8d1QK8X2oDSBr0FlY6Ffb/SfY6e9KpgMWdllA4R17f+9MHAVuj7Upg8sAY19zWcUSOQIuQlNIIQJ7j6a6PxqcnIVPvOg1gWsVMORZdOm6HNA9S+oGZXRtSy4Oyny7uh41CjvSfv2fqw2C6uALEyDx+Mqb6pbfS8J+DSUkotdKI6NcduxRNglzH11adjCxstxQGjDw/SZU6r1Du10ftbPknmyC4+AbSZUZBw== terraform@vm"  # user should use their own public key 
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
}
