##-----------------------------------------------------------------------------
## Provider
##-----------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.4"
  name        = "nva"
  environment = "qa"
  label_order = ["name", "environment", "location"]
  location    = "westus3"
}

##-----------------------------------------------------------------------------
## Virtual Network
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.4"
  name                = "nva"
  environment         = "qa"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/22"]
}

##-----------------------------------------------------------------------------
## Subnets: management, untrust (internet facing) and trust (internal)
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.3"
  environment          = "qa"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    { name = "management", subnet_prefixes = ["10.0.0.0/27"] },
    { name = "untrust", subnet_prefixes = ["10.0.0.32/27"] },
    { name = "trust", subnet_prefixes = ["10.0.0.64/27"] },
  ]
}

##-----------------------------------------------------------------------------
## Network virtual appliance from a marketplace image, with three interfaces.
## The default interface is the primary one (management); the additional
## interfaces attach after it in list order.
##-----------------------------------------------------------------------------
module "nva" {
  source              = "../.."
  name                = "nva"
  environment         = "qa"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  is_vm_linux          = true
  vm_size              = "Standard_D8s_v5"
  vm_availability_zone = "1"
  admin_username       = "nvaadmin"

  # Marketplace image with a purchase plan. The agreement is per subscription
  # and plan: accept it on one VM only.
  image_publisher               = "paloaltonetworks"
  image_offer                   = "vmseries-flex"
  image_sku                     = "bundle1"
  image_version                 = "latest"
  plan_enabled                  = true
  plan_publisher                = "paloaltonetworks"
  plan_product                  = "vmseries-flex"
  plan_name                     = "bundle1"
  marketplace_agreement_enabled = true

  # Appliances read their first-boot parameters from custom data (base64).
  custom_data = base64encode("type=dhcp-client\nhostname=nva-qa")

  # Primary interface: management, no public IP.
  subnet_id                     = module.subnet.subnet_ids["management"]
  private_ip_address_allocation = "Dynamic"
  public_ip_enabled             = false
  network_interface_sg_enabled  = false

  additional_network_interfaces = [
    {
      name                           = "untrust"
      subnet_id                      = module.subnet.subnet_ids["untrust"]
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      public_ip_enabled              = true
      public_ip_zones                = ["1"]
    },
    {
      name                           = "trust"
      subnet_id                      = module.subnet.subnet_ids["trust"]
      ip_forwarding_enabled          = true
      accelerated_networking_enabled = true
      private_ip_address             = "10.0.0.70"
    },
  ]

  disk_size_gb                     = 60
  enable_disk_encryption_set       = false
  enable_maintenance_configuration = false
  diagnostic_setting_enable        = false
}
