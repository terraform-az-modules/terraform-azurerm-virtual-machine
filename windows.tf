resource "azurerm_windows_virtual_machine" "win_vm" {
  count                        = var.is_vm_windows && var.enable ? 1 : 0
  name                         = var.resource_position_prefix ? format("vm-%s", local.name) : format("%s-vm", local.name)
  computer_name                = var.computer_name != null ? var.computer_name : (var.resource_position_prefix ? format("win-vm-%s", local.name) : format("%s-win-vm", local.name))
  resource_group_name          = var.resource_group_name
  location                     = var.location
  network_interface_ids        = [azurerm_network_interface.default[0].id]
  size                         = var.vm_size
  admin_username               = var.admin_username
  admin_password               = var.admin_password
  source_image_id              = var.source_image_id
  provision_vm_agent           = var.provision_vm_agent
  allow_extension_operations   = var.allow_extension_operations
  dedicated_host_id            = var.dedicated_host_id
  automatic_updates_enabled    = var.enable_automatic_updates
  license_type                 = var.license_type
  availability_set_id          = var.availability_set_enabled ? azurerm_availability_set.default[0].id : null
  encryption_at_host_enabled   = var.enable_encryption_at_host
  proximity_placement_group_id = var.proximity_placement_group_id
  patch_mode                   = var.windows_patch_mode
  patch_assessment_mode        = var.patch_assessment_mode
  zone                         = var.vm_availability_zone
  timezone                     = var.timezone
  tags                         = module.labels.tags
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_enabled ? [1] : []
    content {
      storage_account_uri = var.blob_endpoint
    }
  }
  dynamic "additional_capabilities" {
    for_each = var.additional_capabilities_enabled ? [1] : []
    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }
  dynamic "identity" {
    for_each = var.identity_enabled ? [1] : []
    content {
      type         = var.vm_identity_type
      identity_ids = var.identity_ids
    }
  }
  os_disk {
    name                      = var.resource_position_prefix ? format("osdisk-%s", local.name) : format("%s-osdisk", local.name)
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.caching
    disk_encryption_set_id    = var.enable_disk_encryption_set ? azurerm_disk_encryption_set.main[0].id : null
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
    dynamic "diff_disk_settings" {
      for_each = var.diff_disk_settings == null ? [] : ["diff_disk_settings"]
      content {
        option    = var.diff_disk_settings.option
        placement = var.diff_disk_settings.placement
      }
    }
  }
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.custom_image_id != null ? var.image_publisher : ""
      offer     = var.custom_image_id != null ? var.image_offer : ""
      sku       = var.custom_image_id != null ? var.image_sku : ""
      version   = var.custom_image_id != null ? var.image_version : ""
    }
  }
  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? [] : ["termination_notification"]
    content {
      enabled = var.termination_notification.enabled
      timeout = var.termination_notification.timeout
    }
  }
  dynamic "winrm_listener" {
    for_each = var.winrm_listeners
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = winrm_listener.value.certificate_url
    }
  }
  depends_on = [
    azurerm_role_assignment.azurerm_disk_encryption_set_key_vault_access
  ]
}
