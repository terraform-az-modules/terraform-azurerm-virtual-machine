resource "azurerm_linux_virtual_machine" "default" {
  count                           = var.is_vm_linux && var.enable ? 1 : 0
  name                            = var.resource_position_prefix ? format("vm-%s", local.name) : format("%s-vm", local.name)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.disable_password_authentication ? null : var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids           = [azurerm_network_interface.default[0].id]
  source_image_id                 = var.source_image_id
  availability_set_id             = var.availability_set_enabled ? azurerm_availability_set.default[0].id : null
  proximity_placement_group_id    = var.proximity_placement_group_id
  encryption_at_host_enabled      = var.enable_encryption_at_host
  patch_assessment_mode           = var.patch_assessment_mode
  patch_mode                      = var.linux_patch_mode
  provision_vm_agent              = var.provision_vm_agent
  zone                            = var.vm_availability_zone
  allow_extension_operations      = var.allow_extension_operations
  tags                            = module.labels.tags
  user_data                       = var.user_data
  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.public_key
    }
  }
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
  dynamic "plan" {
    for_each = var.plan_enabled ? [1] : []
    content {
      name      = var.plan_name
      publisher = var.plan_publisher
      product   = var.plan_product
    }
  }
  os_disk {
    name                      = var.resource_position_prefix ? format("osdisk-%s", local.name) : format("%s-osdisk", local.name)
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.caching
    disk_encryption_set_id    = var.enable_disk_encryption_set ? azurerm_disk_encryption_set.main[0].id : null
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.write_accelerator_enabled
  }
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null && var.storage_image_reference_enabled ? [1] : []
    content {
      publisher = var.image_publisher
      offer     = var.image_offer
      sku       = var.image_sku
      version   = var.image_version
    }
  }
  dynamic "termination_notification" {
    for_each = var.termination_notification == null ? [] : ["termination_notification"]
    content {
      enabled = var.termination_notification.enabled
      timeout = var.termination_notification.timeout
    }
  }
  depends_on = [
    azurerm_role_assignment.azurerm_disk_encryption_set_key_vault_access
  ]
}
