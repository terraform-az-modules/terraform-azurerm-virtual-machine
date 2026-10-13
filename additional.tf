##-----------------------------------------------------------------------------
## Additional Network Interfaces - Extra NICs for multi-homed VMs such as
## network virtual appliances (management, untrust, trust). The default NIC
## stays the primary one; these attach after it in list order.
##-----------------------------------------------------------------------------
resource "azurerm_public_ip" "additional" {
  for_each                = var.enable ? { for nic in var.additional_network_interfaces : nic.name => nic if nic.public_ip_enabled } : {}
  name                    = var.resource_position_prefix ? format("pip-%s-%s", local.name, each.key) : format("%s-%s-pip", local.name, each.key)
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku                     = "Standard"
  allocation_method       = "Static"
  zones                   = each.value.public_ip_zones
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  ddos_protection_mode    = var.ddos_protection_mode
  tags                    = module.labels.tags
}

resource "azurerm_network_interface" "additional" {
  #checkov:skip=CKV_AZURE_118:IP forwarding is a per-interface input, required on the data interfaces of network virtual appliances
  for_each                       = var.enable ? { for nic in var.additional_network_interfaces : nic.name => nic } : {}
  name                           = var.resource_position_prefix ? format("nic-%s-%s", local.name, each.key) : format("%s-%s-nic", local.name, each.key)
  resource_group_name            = var.resource_group_name
  location                       = var.location
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  tags                           = module.labels.tags
  ip_configuration {
    name                          = format("ip-config-%s", each.key)
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address == null ? "Dynamic" : "Static"
    private_ip_address            = each.value.private_ip_address
    public_ip_address_id          = each.value.public_ip_enabled ? azurerm_public_ip.additional[each.key].id : null
    primary                       = true
  }
}

##-----------------------------------------------------------------------------
## Marketplace Agreement - Accepts the legal terms of a marketplace image plan.
## The acceptance is per subscription and plan, so enable it on one VM only.
##-----------------------------------------------------------------------------
resource "azurerm_marketplace_agreement" "default" {
  count     = var.enable && var.marketplace_agreement_enabled ? 1 : 0
  publisher = var.plan_publisher
  offer     = var.plan_product
  plan      = var.plan_name
}
