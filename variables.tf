##-----------------------------------------------------------------------------
## Naming convention
##-----------------------------------------------------------------------------
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "resource_position_prefix" {
  type        = bool
  default     = true
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
## Labels
##-----------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-virtual-machine"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "location" {
  type        = string
  default     = ""
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']."
}

##-----------------------------------------------------------------------------
## Global Variables
##-----------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Log Analytics."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

##-----------------------------------------------------------------------------
## Virtual Machine
##-----------------------------------------------------------------------------
variable "vm_size" {
  type        = string
  default     = ""
  description = "Specifies the size of the Virtual Machine (e.g. Standard_D2s_v3)."
}

variable "is_vm_windows" {
  type        = bool
  default     = false
  description = "Set to true to create Windows Virtual Machine."
}

variable "is_vm_linux" {
  type        = bool
  default     = false
  description = "Set to true to create Linux Virtual Machine."
}

variable "vm_availability_zone" {
  type        = any
  default     = null
  description = "Specifies the Availability Zone in which this Virtual Machine should be located."
}

variable "computer_name" {
  type        = string
  default     = null
  description = "Specifies the hostname of the Virtual Machine."
}

variable "admin_username" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Specifies the name of the local administrator account. Required for Windows VM."
}

variable "admin_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "The password for the local administrator account. Required for Windows VM."
}

variable "public_key" {
  type        = string
  default     = null
  description = "SSH public key for authentication (e.g. `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ`)."
  sensitive   = true
}

variable "disable_password_authentication" {
  type        = bool
  default     = true
  description = "Specifies whether password authentication should be disabled for Linux VMs."
}

variable "user_data" {
  type        = string
  default     = null
  description = "A string containing custom data/cloud-init script for the VM."
}

##-----------------------------------------------------------------------------
## VM Disk Configuration
##-----------------------------------------------------------------------------
variable "os_disk_storage_account_type" {
  type        = string
  default     = "StandardSSD_LRS"
  description = "The Type of Storage Account for the OS Disk. Possible values: Standard_LRS, StandardSSD_LRS, Premium_LRS."
}

variable "disk_size_gb" {
  type        = number
  default     = 30
  description = "Specifies the size of the OS Disk in gigabytes."
}

variable "caching" {
  type        = string
  default     = "ReadWrite"
  description = "Specifies the caching requirements for the OS Disk. Possible values: None, ReadOnly, ReadWrite."
}

variable "create_option" {
  type        = string
  default     = "Empty"
  description = "Specifies how the managed Disk should be created. Possible values: Attach, FromImage."
}

variable "write_accelerator_enabled" {
  type        = bool
  default     = false
  description = "Specifies if Write Accelerator is enabled on the disk. Only for Premium_LRS with no caching and M-Series VMs."
}

variable "enable_os_disk_write_accelerator" {
  type        = bool
  default     = false
  description = "Should Write Accelerator be Enabled for the OS Disk? Requires Premium_LRS storage and None caching."
}

variable "data_disks" {
  type = list(object({
    name                 = string
    storage_account_type = string
    disk_size_gb         = number
    caching              = optional(string, "ReadWrite")
  }))
  default     = []
  description = "List of managed Data Disks to create for the VM."
}

variable "diff_disk_settings" {
  type = object({
    option    = string
    placement = optional(string)
  })
  default     = null
  description = "Ephemeral disk settings for the OS disk. Option can be 'Local' and placement can be 'CacheDisk' or 'ResourceDisk'."
}

##-----------------------------------------------------------------------------
## VM Image 
##-----------------------------------------------------------------------------
variable "storage_image_reference_enabled" {
  type        = bool
  default     = true
  description = "Whether to use the platform image reference or a custom image."
}

variable "source_image_id" {
  type        = any
  default     = null
  description = "The ID of a custom Image to use for the VM."
}

variable "custom_image_id" {
  type        = string
  default     = ""
  description = "Specifies the ID of the Custom Image for the Virtual Machine."
}

variable "image_publisher" {
  type        = string
  default     = ""
  description = "Specifies the publisher of the platform image (e.g., MicrosoftWindowsServer, Canonical)."
}

variable "image_offer" {
  type        = string
  default     = ""
  description = "Specifies the offer of the platform image (e.g., WindowsServer, UbuntuServer)."
}

variable "image_sku" {
  type        = string
  default     = ""
  description = "Specifies the SKU of the platform image (e.g., 2019-Datacenter, 18.04-LTS)."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Specifies the version of the platform image. Defaults to latest."
}

##-----------------------------------------------------------------------------
## VM Plan  (Marketplace Images)
##-----------------------------------------------------------------------------
variable "plan_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the marketplace image purchase plan."
}

variable "plan_name" {
  type        = string
  default     = ""
  description = "Specifies the name of the image from the marketplace."
}

variable "plan_publisher" {
  type        = string
  default     = ""
  description = "Specifies the publisher of the marketplace image."
}

variable "plan_product" {
  type        = string
  default     = ""
  description = "Specifies the product of the marketplace image."
}

##-----------------------------------------------------------------------------
## Network Interface
##-----------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for the private endpoint."
}

variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "List of IP addresses of DNS servers for the network interface."
}

variable "enable_ip_forwarding" {
  type        = bool
  default     = false
  description = "Should IP Forwarding be enabled on the network interface?"
}

variable "enable_accelerated_networking" {
  type        = bool
  default     = false
  description = "Should Accelerated Networking be enabled on the network interface?"
}

variable "internal_dns_name_label" {
  type        = string
  default     = null
  description = "The DNS Name used for internal communications between VMs in the same Virtual Network."
}

variable "private_ip_address_version" {
  type        = string
  default     = "IPv4"
  description = "The IP Version to use. Possible values: IPv4, IPv6."
}

variable "private_ip_address_allocation" {
  type        = string
  default     = "Static"
  description = "The allocation method for the Private IP Address. Possible values: Dynamic, Static."
}

variable "private_ip_addresses" {
  type        = list(any)
  default     = []
  description = "List of Static IP Addresses to assign to the network interface."
}

variable "primary" {
  type        = bool
  default     = true
  description = "Is this the Primary IP Configuration? Must be true for the first ip_configuration."
}

variable "network_interface_sg_enabled" {
  type        = bool
  default     = true
  description = "Whether to attach a Network Security Group to the network interface."
}

variable "network_security_group_id" {
  type        = string
  default     = ""
  description = "The ID of the Network Security Group to attach to the Network Interface."
}

##-----------------------------------------------------------------------------
## Public IP
##-----------------------------------------------------------------------------
variable "public_ip_enabled" {
  type        = bool
  default     = false
  description = "Whether to create a public IP for the VM."
}

variable "sku" {
  type        = string
  default     = "Basic"
  description = "The SKU of the Public IP. Possible values: Basic, Standard."
}

variable "allocation_method" {
  type        = string
  default     = "Static"
  description = "Defines the allocation method for the Public IP. Possible values: Static, Dynamic."
}

variable "ip_version" {
  type        = string
  default     = "IPv4"
  description = "The IP Version for the Public IP. Possible values: IPv4, IPv6."
}

variable "idle_timeout_in_minutes" {
  type        = number
  default     = 10
  description = "Timeout for the TCP idle connection. Value between 4 and 60 minutes."
}

variable "domain_name_label" {
  type        = string
  default     = null
  description = "Label for the Domain Name. Will be used to make up the FQDN."
}

variable "reverse_fqdn" {
  type        = string
  default     = ""
  description = "A fully qualified domain name that resolves to this public IP address."
}

variable "public_ip_prefix_id" {
  type        = string
  default     = null
  description = "ID of the public IP prefix resource to allocate the public IP from."
}

variable "ddos_protection_mode" {
  type        = string
  default     = "VirtualNetworkInherited"
  description = "The DDoS protection mode of the public IP."
}

##-----------------------------------------------------------------------------
## Availability Set
##-----------------------------------------------------------------------------
variable "availability_set_enabled" {
  type        = bool
  default     = false
  description = "Whether to create an availability set for the VMs."
}

variable "platform_update_domain_count" {
  type        = number
  default     = 5
  description = "Specifies the number of update domains in the availability set."
}

variable "platform_fault_domain_count" {
  type        = number
  default     = 3
  description = "Specifies the number of fault domains in the availability set."
}

variable "managed" {
  type        = bool
  default     = true
  description = "Specifies whether the availability set is managed (aligned) or classic."
}

variable "proximity_placement_group_id" {
  type        = string
  default     = null
  description = "The ID of the Proximity Placement Group to assign to the VM."
}

variable "dedicated_host_id" {
  type        = string
  default     = null
  description = "The ID of a Dedicated Host where this VM should run. Conflicts with dedicated_host_group_id."
}

##-----------------------------------------------------------------------------
## VM Identity
##-----------------------------------------------------------------------------
variable "identity_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable managed identity for the VM."
}

variable "vm_identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "The Managed Service Identity Type. Possible values: SystemAssigned, UserAssigned."
}

variable "identity_ids" {
  type        = list(any)
  default     = []
  description = "List of user managed identity IDs to assign to the VM."
}

##-----------------------------------------------------------------------------
## VM Additional Features
##-----------------------------------------------------------------------------
variable "boot_diagnostics_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable boot diagnostics for the VM."
}

variable "blob_endpoint" {
  type        = string
  default     = ""
  description = "The Storage Account's Blob Endpoint for VM diagnostic files."
}

variable "additional_capabilities_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable additional capabilities for the VM."
}

variable "ultra_ssd_enabled" {
  type        = bool
  default     = false
  description = "Should Ultra SSD disks be enabled for this VM?"
}

variable "provision_vm_agent" {
  type        = bool
  default     = true
  description = "Should the Azure VM Agent be installed on the VM?"
}

variable "license_type" {
  type        = string
  default     = "Windows_Client"
  description = "BYOL license type for Windows VMs. Possible values: Windows_Client, Windows_Server."
}

variable "timezone" {
  type        = string
  default     = ""
  description = "Specifies the time zone of the VM."
}

variable "enable_encryption_at_host" {
  type        = bool
  default     = true
  description = "Flag to control Disk Encryption at host level."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether public network access is allowed for the VM."
}

variable "allow_extension_operations" {
  type        = bool
  default     = false
  description = "Whether extension operations are allowed on the VM"
}

variable "termination_notification" {
  type = object({
    enabled = optional(bool, false)
    timeout = optional(string, "PT5M")
  })
  default = {
    enabled = true
    timeout = "PT10M"
  }
  description = "Enable termination notification with ISO 8601 timeout (default: enabled=true, timeout=PT10M)."
}

variable "maintenance_configuration_resource_id" {
  type        = string
  default     = ""
  description = "The Azure resource ID of the maintenance configuration to apply to this virtual machine."
}

##-----------------------------------------------------------------------------
## VM Patching
##-----------------------------------------------------------------------------
variable "enable_automatic_updates" {
  type        = bool
  default     = true
  description = "Specifies if Automatic Updates are Enabled for Windows VMs."
}

variable "windows_patch_mode" {
  type        = string
  default     = "AutomaticByPlatform"
  description = "Mode of in-guest patching for Windows VMs. Possible values: Manual, AutomaticByOS, AutomaticByPlatform."
}

variable "linux_patch_mode" {
  type        = string
  default     = "ImageDefault"
  description = "Mode of in-guest patching for Linux VMs. Possible values: AutomaticByPlatform, ImageDefault."
}

variable "patch_assessment_mode" {
  type        = string
  default     = "ImageDefault"
  description = "Mode of VM Guest Patching. Possible values: AutomaticByPlatform, ImageDefault."
}

##-----------------------------------------------------------------------------
## VM Extensions
##-----------------------------------------------------------------------------
variable "extensions" {
  type = list(object({
    extension_publisher            = string
    extension_name                 = string
    extension_type                 = string
    extension_type_handler_version = string
    auto_upgrade_minor_version     = bool
    automatic_upgrade_enabled      = bool
    settings                       = optional(string, "{}")
    protected_settings             = optional(string, "{}")
  }))
  default     = []
  description = "List of extensions to install on the Azure Virtual Machine."
}

##-----------------------------------------------------------------------------
## Disk Encryption
##-----------------------------------------------------------------------------
variable "enable_disk_encryption_set" {
  type        = bool
  default     = true
  description = "Whether to enable disk encryption for the VM."
}

variable "key_vault_id" {
  type        = any
  default     = null
  description = "The ID of the Key Vault for disk encryption."
}

variable "key_vault_rbac_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether to use RBAC authorization for Key Vault instead of access policies."
}

variable "vault_sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the Key Vault. Possible values: Standard, Premium."
}

variable "role_definition_name" {
  type        = string
  default     = "Key Vault Crypto Service Encryption User"
  description = "The name of the built-in role for Key Vault encryption."
}

variable "key_type" {
  type        = string
  default     = "RSA-HSM"
  description = "The Key Type for Key Vault. Possible values: EC, EC-HSM, RSA, RSA-HSM."
}

variable "key_size" {
  type        = number
  default     = 2048
  description = "Size of the RSA key in bytes (e.g., 1024, 2048)."
}

variable "key_expiration_date" {
  description = "The expiration date for the Key Vault key"
  type        = string
  default     = "2028-12-31T23:59:59Z" # ISO 8601 format
}

variable "user_object_id" {
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default     = {}
  description = "Map of Principal IDs and Role Definitions to assign in Key Vault."
}

variable "key_permissions" {
  description = "List of Key Vault key permissions"
  type        = list(string)
  default = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "WrapKey",
    "UnwrapKey",
    "List",
    "Decrypt",
    "Sign"
  ]
}

variable "key_opts" {
  description = "List of key operations for Key Vault keys"
  type        = list(string)
  default = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
}


##-----------------------------------------------------------------------------
## Backup
##-----------------------------------------------------------------------------
variable "backup_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable backup for the VM using Recovery Services Vault."
}

variable "vault_service" {
  type        = string
  default     = null
  description = "The ID of the Recovery Services Vault for backups."
}

variable "backup_policy_time" {
  type        = string
  default     = "23:00"
  description = "The time to execute the backup policy."
}

variable "backup_policy_time_zone" {
  type        = string
  default     = "UTC"
  description = "The timezone for the backup policy."
}

variable "backup_policy_frequency" {
  type        = string
  default     = "Daily"
  description = "The frequency for the backup policy. Possible values: Daily, Weekly, Hourly."

  validation {
    condition     = contains(["Daily", "Weekly", "Hourly"], var.backup_policy_frequency)
    error_message = "The value must be set to one of the following: Daily, Weekly, Hourly"
  }
}

variable "backup_policy_type" {
  type        = string
  default     = "V1"
  description = "The version type for the backup policy. Possible values: V1, V2."

  validation {
    condition     = contains(["V1", "V2"], var.backup_policy_type)
    error_message = "The value must be set to one of the following: V1, V2"
  }
}

variable "backup_policy_retention" {
  type = map(object({
    enabled   = bool
    frequency = optional(string)
    count     = optional(string)
    weekdays  = optional(list(string), [])
    weeks     = optional(list(string), [])
  }))
  default     = {}
  description = <<EOT
Retention configuration for different backup frequencies.
Example:
backup_policy_retention = {
  daily = {
    enabled   = true
    frequency = "Daily"
    count     = "7"
    weekdays  = []
    weeks     = []
  }
  weekly = {
    enabled   = false
    frequency = "Weekly"
    count     = "4"
    weekdays  = ["Saturday"]
    weeks     = []
  }
  monthly = {
    enabled   = false
    frequency = "Monthly"
    count     = "3"
    weekdays  = ["Saturday"]
    weeks     = ["Last"]
  }
}
EOT
}

##-----------------------------------------------------------------------------
## Diagnostic Settings
##-----------------------------------------------------------------------------
variable "diagnostic_setting_enable" {
  type        = bool
  default     = true
  description = "Whether to enable diagnostic settings for the VM."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the Log Analytics Workspace for diagnostics."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "The ID of the Storage Account for diagnostic logs."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "The name of the Event Hub for diagnostic data."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "The ID of an Event Hub Namespace Authorization Rule for diagnostics."
}

variable "log_analytics_destination_type" {
  type        = string
  default     = "AzureDiagnostics"
  description = "Destination type for Log Analytics. Possible values: AzureDiagnostics, Dedicated."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Whether diagnostic metrics are enabled."
}

variable "pip_logs" {
  type = object({
    enabled        = bool
    category       = optional(list(string))
    category_group = optional(list(string))
  })
  default = {
    enabled        = true
    category_group = ["AllLogs"]
  }
  description = "Configuration for Public IP diagnostic logs."
}

##-----------------------------------------------------------------------------
## Windows-Specific Configuration
##-----------------------------------------------------------------------------
variable "winrm_listeners" {
  type = set(object({
    protocol        = string
    certificate_url = optional(string)
  }))
  default = [
    {
      protocol        = "Http"
      certificate_url = null
    }
  ]
  nullable    = false
  description = "WinRM listener with protocol (Http/Https); certificate_url needed if using Https (default: Http)."
}

##-----------------------------------------------------------------------------
## Shutdown Schedule
##-----------------------------------------------------------------------------

variable "shutdown_schedule" {
  type = object({
    daily_recurrence_time = string
    notification_settings = object({
      enabled         = bool
      email           = string
      time_in_minutes = string
      webhook_url     = string
    })
    timezone = string
    enabled  = bool
    tags     = map(string)
  })
  default     = null
  description = <<EOT
Configuration for VM auto-shutdown schedule. Set to null to disable shutdown scheduling.

The daily_recurrence_time is in 24-hour format (e.g., "2000" for 8:00 PM).
Notification settings control pre-shutdown alerts via email and webhook.
Timezone should be specified as a valid IANA time zone identifier.
EOT
}


