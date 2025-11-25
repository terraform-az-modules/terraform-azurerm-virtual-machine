##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name           = var.custom_name != null ? var.custom_name : module.labels.id
  pip_diagnostic = var.enable && var.diagnostic_setting_enable && var.public_ip_enabled ? 1 : 0
}