##-----------------------------------------------------------------------------
# Standard Tagging Module – Applies standard tags to all resources for traceability
##-----------------------------------------------------------------------------
module "labels" {
  source = "../labels"
  # version         = "1.0.0"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------
## Network Interface - Creates VM network connectivity with configurable settings
##-----------------------------------------------------------------------------
resource "azurerm_network_interface" "default" {
  count                          = var.enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("nic-%s", local.name) : format("%s-nic", local.name)
  resource_group_name            = var.resource_group_name
  location                       = var.location
  dns_servers                    = var.dns_servers
  ip_forwarding_enabled          = var.enable_ip_forwarding
  accelerated_networking_enabled = var.enable_accelerated_networking
  internal_dns_name_label        = var.internal_dns_name_label
  tags                           = module.labels.tags
  ip_configuration {
    name                          = var.resource_position_prefix ? format("ip-config-%s", local.name) : format("%s-ip-config", local.name)
    subnet_id                     = var.private_ip_address_version == "IPv4" ? var.subnet_id : null
    private_ip_address_version    = var.private_ip_address_version
    private_ip_address_allocation = var.private_ip_address_allocation
    public_ip_address_id          = var.public_ip_enabled ? element(azurerm_public_ip.default[*].id, count.index) : null
    primary                       = var.primary
    private_ip_address            = var.private_ip_address_allocation == "Static" ? element(var.private_ip_addresses, count.index) : null
  }
}

##-----------------------------------------------------------------------------
## Availability Set - High availability for VMs
##-----------------------------------------------------------------------------
resource "azurerm_availability_set" "default" {
  count                        = var.enable && var.availability_set_enabled ? 1 : 0
  name                         = var.resource_position_prefix ? format("avail-%s", local.name) : format("%s-avail", local.name)
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count
  proximity_placement_group_id = var.proximity_placement_group_id
  managed                      = var.managed
  tags                         = module.labels.tags
}

##-----------------------------------------------------------------------------
## Public IP - Creates public IP addresses for internet-facing resources
##-----------------------------------------------------------------------------
resource "azurerm_public_ip" "default" {
  count                   = var.enable && var.public_ip_enabled ? 1 : 0
  name                    = var.resource_position_prefix ? format("pip-%s", local.name) : format("%s-pip", local.name)
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku                     = var.sku
  allocation_method       = var.sku == "Standard" ? "Static" : var.allocation_method
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  reverse_fqdn            = var.reverse_fqdn
  public_ip_prefix_id     = var.public_ip_prefix_id
  ddos_protection_mode    = var.ddos_protection_mode
  tags                    = module.labels.tags
}

##-----------------------------------------------------------------------------
## Network Security Group Association - Links NSGs to VM network interfaces
##-----------------------------------------------------------------------------
resource "azurerm_network_interface_security_group_association" "default" {
  count                     = var.enable && var.network_interface_sg_enabled ? 1 : 0
  network_interface_id      = azurerm_network_interface.default[count.index].id
  network_security_group_id = var.network_security_group_id
}

##-----------------------------------------------------------------------------
## Disk Encryption Set - Provides encryption for VM disks using Key Vault
##-----------------------------------------------------------------------------
resource "azurerm_disk_encryption_set" "main" {
  count               = var.enable && var.enable_disk_encryption_set ? 1 : 0
  name                = var.resource_position_prefix ? format("des-%s", local.name) : format("%s-des", local.name)
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = var.enable_disk_encryption_set ? azurerm_key_vault_key.main[0].id : null
  identity {
    type = "SystemAssigned"
  }
}

##-----------------------------------------------------------------------------
## Key Vault Key - Creates encryption keys for secure VM disk encryption
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "main" {
  count           = var.enable && var.enable_disk_encryption_set ? 1 : 0
  name            = var.resource_position_prefix ? format("kv-%s", local.name) : format("%s-kv", local.name)
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = var.key_size
  expiration_date = var.key_expiration_date
  key_opts        = var.key_opts
}

##-----------------------------------------------------------------------------
## Managed Disk - Creates additional data disks for VM storage
##-----------------------------------------------------------------------------
resource "azurerm_managed_disk" "data_disk" {
  for_each = var.enable ? { for it, data_disk in var.data_disks : data_disk.name => {
    it : it,
    data_disk : data_disk,
    }
  } : {}
  name                          = format("%s-%s-vm-disk", local.name, each.value.data_disk.name)
  resource_group_name           = var.resource_group_name
  location                      = var.location
  storage_account_type          = lookup(each.value.data_disk, "storage_account_type", "StandardSSD_LRS")
  create_option                 = var.create_option
  public_network_access_enabled = var.public_network_access_enabled
  disk_size_gb                  = each.value.data_disk.disk_size_gb
  disk_encryption_set_id        = var.enable_disk_encryption_set ? azurerm_disk_encryption_set.main[0].id : null
  depends_on = [
    azurerm_role_assignment.azurerm_disk_encryption_set_key_vault_access
  ]
}

##-----------------------------------------------------------------------------
## Disk Attachment - Connects managed disks to virtual machines
##-----------------------------------------------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each = var.enable ? { for it, data_disk in var.data_disks : data_disk.name => {
    it : it,
    data_disk : data_disk,
    }
  } : {}
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = var.is_vm_windows ? azurerm_windows_virtual_machine.win_vm[0].id : azurerm_linux_virtual_machine.default[0].id
  lun                = each.value.it
  caching            = each.value.data_disk.caching
}

##-----------------------------------------------------------------------------
## Public IP Diagnostic Setting - Configures monitoring for public IP resources
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "pip_diagnostic" {
  count                          = local.pip_diagnostic
  name                           = var.resource_position_prefix ? format("vm-pip-diag-%s", local.name) : format("%s-vm-pip-diag", local.name)
  target_resource_id             = azurerm_public_ip.default[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  dynamic "enabled_log" {
    for_each = var.pip_logs.enabled ? var.pip_logs.category != null ? var.pip_logs.category : var.pip_logs.category_group : []
    content {
      category       = var.pip_logs.category != null ? enabled_log.value : null
      category_group = var.pip_logs.category == null ? enabled_log.value : null
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##-----------------------------------------------------------------------------
## NIC Diagnostic Setting - Configures monitoring for network interfaces
##-----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "nic_diagnostic" {
  count                          = var.enable && var.diagnostic_setting_enable ? 1 : 0
  name                           = var.resource_position_prefix ? format("vm-nic-diag-%s", local.name) : format("%s-vm-nic-diag", local.name)
  target_resource_id             = azurerm_network_interface.default[0].id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }
  lifecycle {
    ignore_changes = [log_analytics_destination_type]
  }
}

##-----------------------------------------------------------------------------
## Recovery Services Vault - Creates backup storage for VM recovery
##-----------------------------------------------------------------------------
resource "azurerm_recovery_services_vault" "main" {
  count                         = var.backup_enabled && var.enable ? 1 : 0
  name                          = var.resource_position_prefix ? format("vm-service-vault-%s", local.name) : format("%s-vm-service-vault", local.name)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.vault_sku
  tags                          = module.labels.tags
  public_network_access_enabled = var.public_network_access_enabled
  identity {
    type = "SystemAssigned"
  }
}

##-----------------------------------------------------------------------------
## Backup Policy - Defines VM backup frequency and retention settings
##-----------------------------------------------------------------------------
resource "azurerm_backup_policy_vm" "policy" {
  count               = var.backup_enabled && var.enable ? 1 : 0
  name                = var.resource_position_prefix ? format("policy-vm-%s", local.name) : format("%s-policy-vm", local.name)
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main[count.index].name
  policy_type         = var.backup_policy_type != null ? var.backup_policy_type : "V2"
  timezone            = var.backup_policy_time_zone != null ? var.backup_policy_time_zone : "UTC"
  backup {
    frequency = var.backup_policy_frequency != null ? var.backup_policy_frequency : "Daily"
    time      = var.backup_policy_time != null ? var.backup_policy_time : "23:00"
  }
  dynamic "retention_daily" {
    for_each = try(var.backup_policy_retention["daily"].enabled, false) ? [1] : []
    content {
      count = try(var.backup_policy_retention["daily"].count, 7)
    }
  }
  dynamic "retention_weekly" {
    for_each = try(var.backup_policy_retention["weekly"].enabled, false) ? [1] : []
    content {
      count    = try(var.backup_policy_retention["weekly"].count, 4)
      weekdays = try(var.backup_policy_retention["weekly"].weekdays, ["Sunday"])
    }
  }
  dynamic "retention_monthly" {
    for_each = try(var.backup_policy_retention["monthly"].enabled, false) ? [1] : []
    content {
      count    = try(var.backup_policy_retention["monthly"].count, 12)
      weekdays = try(var.backup_policy_retention["monthly"].weekdays, ["Sunday"])
      weeks    = try(var.backup_policy_retention["monthly"].weeks, ["First"])
    }
  }
}

##-----------------------------------------------------------------------------
## Protected VM - Associates VMs with backup policies for automated backups
##-----------------------------------------------------------------------------
resource "azurerm_backup_protected_vm" "main" {
  count               = var.enable && var.backup_enabled ? 1 : 0
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main[count.index].name
  backup_policy_id    = azurerm_backup_policy_vm.policy[count.index].id
  source_vm_id        = var.is_vm_linux ? azurerm_linux_virtual_machine.default[count.index].id : azurerm_windows_virtual_machine.win_vm[count.index].id
}

##-----------------------------------------------------------------------------
## VM Auto-Shutdown Schedule - Configures automatic shutdown for cost optimization
##-----------------------------------------------------------------------------
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_schedule" {
  count                 = var.enable && var.shutdown_schedule != null ? 1 : 0
  daily_recurrence_time = var.shutdown_schedule.daily_recurrence_time
  location              = var.location
  timezone              = var.shutdown_schedule.timezone
  virtual_machine_id    = var.is_vm_windows ? azurerm_windows_virtual_machine.win_vm[0].id : azurerm_linux_virtual_machine.default[0].id
  enabled               = var.shutdown_schedule.enabled
  tags                  = var.shutdown_schedule.tags
  notification_settings {
    enabled         = var.shutdown_schedule.notification_settings.enabled
    email           = var.shutdown_schedule.notification_settings.email
    time_in_minutes = var.shutdown_schedule.notification_settings.time_in_minutes
    webhook_url     = var.shutdown_schedule.notification_settings.webhook_url
  }
  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.data_disk
  ]
}

resource "azurerm_maintenance_configuration" "main" {
  count                    = var.enable && var.enable_maintenance_configuration ? 1 : 0
  name                     = var.resource_position_prefix ? format("mc-vm-%s", local.name) : format("%s-mc-vm", local.name)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  scope                    = var.maintenance_configuration_scope
  visibility               = var.maintenance_configuration_visibility
  in_guest_user_patch_mode = var.maintenance_configuration_scope == "InGuestPatch" ? var.maintenance_in_guest_user_patch_mode : null
  properties               = var.maintenance_configuration_properties
  tags                     = module.labels.tags
  dynamic "window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      start_date_time      = window.value.start_date_time
      expiration_date_time = window.value.expiration_date_time
      duration             = window.value.duration
      time_zone            = window.value.time_zone
      recur_every          = window.value.recur_every
    }
  }
  dynamic "install_patches" {
    for_each = var.maintenance_configuration_scope == "InGuestPatch" && var.maintenance_install_patches != null ? [var.maintenance_install_patches] : []
    content {
      reboot = install_patches.value.reboot
      dynamic "linux" {
        for_each = !var.is_vm_windows && install_patches.value.linux != null ? [install_patches.value.linux] : []
        content {
          classifications_to_include    = linux.value.classifications_to_include
          package_names_mask_to_exclude = linux.value.package_names_mask_to_exclude
          package_names_mask_to_include = linux.value.package_names_mask_to_include
        }
      }
      dynamic "windows" {
        for_each = var.is_vm_windows && install_patches.value.windows != null ? [install_patches.value.windows] : []
        content {
          classifications_to_include = windows.value.classifications_to_include
          kb_numbers_to_exclude      = windows.value.kb_numbers_to_exclude
          kb_numbers_to_include      = windows.value.kb_numbers_to_include
        }
      }
    }
  }
}

##-----------------------------------------------------------------------------
## Maintenance Assignment - Associates VMs with maintenance configurations
##-----------------------------------------------------------------------------
resource "azurerm_maintenance_assignment_virtual_machine" "vm_assign" {
  count                        = var.enable && var.enable_maintenance_configuration ? 1 : 0
  location                     = var.location
  maintenance_configuration_id = azurerm_maintenance_configuration.main[0].id
  virtual_machine_id           = var.is_vm_windows ? azurerm_windows_virtual_machine.win_vm[0].id : azurerm_linux_virtual_machine.default[0].id
}