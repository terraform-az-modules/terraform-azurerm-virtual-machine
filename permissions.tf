##-----------------------------------------------------------------------------
## Role Assignment - Grants disk encryption identity access to Key Vault
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "azurerm_disk_encryption_set_key_vault_access" {
  count                = var.enabled && var.enable_disk_encryption_set ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = var.role_definition_name
  principal_id         = azurerm_disk_encryption_set.example[0].identity[0].principal_id
}

##-----------------------------------------------------------------------------
## AD Role Assignment - Assigns Azure AD roles to users for VM access
##-----------------------------------------------------------------------------
resource "azurerm_role_assignment" "ad_role_assignment" {
  for_each             = var.enabled ? var.user_object_id : {}
  scope                = var.is_vm_windows ? azurerm_windows_virtual_machine.win_vm[0].id : azurerm_linux_virtual_machine.default[0].id
  role_definition_name = lookup(each.value, "role_definition_name", "")
  principal_id         = lookup(each.value, "principal_id", "")
}