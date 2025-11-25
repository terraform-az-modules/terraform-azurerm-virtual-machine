##-----------------------------------------------------------------------------
## VM Extension - Installs monitoring agents and other extensions on VMs
##-----------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "vm_insight_monitor_agent" {
  for_each                   = var.enable ? { for extension in var.extensions : extension.extension_name => extension } : {}
  name                       = each.value.extension_name
  virtual_machine_id         = var.is_vm_windows ? azurerm_windows_virtual_machine.win_vm[0].id : azurerm_linux_virtual_machine.default[0].id
  publisher                  = each.value.extension_publisher
  type                       = each.value.extension_type
  type_handler_version       = each.value.extension_type_handler_version
  auto_upgrade_minor_version = lookup(each.value, "auto_upgrade_minor_version", null)
  automatic_upgrade_enabled  = lookup(each.value, "automatic_upgrade_enabled", null)
  settings                   = lookup(each.value, "settings", null)
  protected_settings         = lookup(each.value, "protected_settings", null)
  tags                       = module.labels.tags
}