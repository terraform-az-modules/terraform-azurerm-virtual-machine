## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_capabilities\_enabled | Whether to enable additional capabilities for the VM. | `bool` | `false` | no |
| admin\_password | The password for the local administrator account. Required for Windows VM. | `string` | `"Password@123"` | no |
| admin\_username | Specifies the name of the local administrator account. Required for Windows VM. | `string` | `""` | no |
| allocation\_method | Defines the allocation method for the Public IP. Possible values: Static, Dynamic. | `string` | `"Static"` | no |
| allow\_extension\_operations | Whether extension operations are allowed on the VM | `bool` | `false` | no |
| availability\_set\_enabled | Whether to create an availability set for the VMs. | `bool` | `false` | no |
| backup\_enabled | Whether to enable backup for the VM using Recovery Services Vault. | `bool` | `false` | no |
| backup\_policy\_frequency | The frequency for the backup policy. Possible values: Daily, Weekly, Hourly. | `string` | `"Daily"` | no |
| backup\_policy\_retention | Retention configuration for different backup frequencies. | <pre>map(object({<br>    enabled   = bool<br>    frequency = optional(string)<br>    count     = optional(number)<br>    weekdays  = optional(list(string), [])<br>    weeks     = optional(list(string), [])<br>  }))</pre> | <pre>{<br>  "daily": {<br>    "enabled": false<br>  },<br>  "monthly": {<br>    "enabled": false<br>  },<br>  "weekly": {<br>    "enabled": false<br>  }<br>}</pre> | no |
| backup\_policy\_time | The time to execute the backup policy. | `string` | `"23:00"` | no |
| backup\_policy\_time\_zone | The timezone for the backup policy. | `string` | `"UTC"` | no |
| backup\_policy\_type | The version type for the backup policy. Possible values: V1, V2. | `string` | `"V1"` | no |
| blob\_endpoint | The Storage Account's Blob Endpoint for VM diagnostic files. | `string` | `""` | no |
| boot\_diagnostics\_enabled | Whether to enable boot diagnostics for the VM. | `bool` | `false` | no |
| caching | Specifies the caching requirements for the OS Disk. Possible values: None, ReadOnly, ReadWrite. | `string` | `"ReadWrite"` | no |
| computer\_name | Specifies the hostname of the Virtual Machine. | `string` | `null` | no |
| create\_option | Specifies how the managed Disk should be created. Possible values: Attach, FromImage. | `string` | `"Empty"` | no |
| custom\_name | Override default naming convention | `string` | `null` | no |
| data\_disks | List of managed Data Disks to create for the VM. | <pre>list(object({<br>    name                 = string<br>    storage_account_type = string<br>    disk_size_gb         = number<br>    caching              = optional(string, "ReadWrite")<br>  }))</pre> | `[]` | no |
| ddos\_protection\_mode | The DDoS protection mode of the public IP. | `string` | `"VirtualNetworkInherited"` | no |
| dedicated\_host\_id | The ID of a Dedicated Host where this VM should run. Conflicts with dedicated\_host\_group\_id. | `string` | `null` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| diagnostic\_setting\_enable | Whether to enable diagnostic settings for the VM. | `bool` | `true` | no |
| diff\_disk\_settings | Ephemeral disk settings for the OS disk. Option can be 'Local' and placement can be 'CacheDisk' or 'ResourceDisk'. | <pre>object({<br>    option    = string<br>    placement = optional(string)<br>  })</pre> | `null` | no |
| disable\_password\_authentication | Specifies whether password authentication should be disabled for Linux VMs. | `bool` | `true` | no |
| disk\_size\_gb | Specifies the size of the OS Disk in gigabytes. | `number` | `30` | no |
| dns\_servers | List of IP addresses of DNS servers for the network interface. | `list(string)` | `[]` | no |
| domain\_name\_label | Label for the Domain Name. Will be used to make up the FQDN. | `string` | `null` | no |
| enable | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| enable\_accelerated\_networking | Should Accelerated Networking be enabled on the network interface? | `bool` | `false` | no |
| enable\_automatic\_updates | Specifies if Automatic Updates are Enabled for Windows VMs. | `bool` | `true` | no |
| enable\_disk\_encryption\_set | Whether to enable disk encryption for the VM. | `bool` | `true` | no |
| enable\_encryption\_at\_host | Flag to control Disk Encryption at host level. | `bool` | `true` | no |
| enable\_ip\_forwarding | Should IP Forwarding be enabled on the network interface? | `bool` | `false` | no |
| enable\_maintenance\_configuration | Enable maintenance configuration for VMs | `bool` | `false` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | The ID of an Event Hub Namespace Authorization Rule for diagnostics. | `string` | `null` | no |
| eventhub\_name | The name of the Event Hub for diagnostic data. | `string` | `null` | no |
| extensions | List of extensions to install on the Azure Virtual Machine. | <pre>list(object({<br>    extension_publisher            = string<br>    extension_name                 = string<br>    extension_type                 = string<br>    extension_type_handler_version = string<br>    auto_upgrade_minor_version     = bool<br>    automatic_upgrade_enabled      = bool<br>    settings                       = optional(string, "{}")<br>    protected_settings             = optional(string, "{}")<br>  }))</pre> | `[]` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| identity\_enabled | Whether to enable managed identity for the VM. | `bool` | `true` | no |
| identity\_ids | List of user managed identity IDs to assign to the VM. | `list(any)` | `[]` | no |
| idle\_timeout\_in\_minutes | Timeout for the TCP idle connection. Value between 4 and 60 minutes. | `number` | `10` | no |
| image\_offer | Specifies the offer of the platform image (e.g., WindowsServer, UbuntuServer). | `string` | `""` | no |
| image\_publisher | Specifies the publisher of the platform image (e.g., MicrosoftWindowsServer, Canonical). | `string` | `""` | no |
| image\_sku | Specifies the SKU of the platform image (e.g., 2019-Datacenter, 18.04-LTS). | `string` | `""` | no |
| image\_version | Specifies the version of the platform image. Defaults to latest. | `string` | `"latest"` | no |
| internal\_dns\_name\_label | The DNS Name used for internal communications between VMs in the same Virtual Network. | `string` | `null` | no |
| ip\_version | The IP Version for the Public IP. Possible values: IPv4, IPv6. | `string` | `"IPv4"` | no |
| is\_vm\_linux | Set to true to create Linux Virtual Machine. | `bool` | `false` | no |
| is\_vm\_windows | Set to true to create Windows Virtual Machine. | `bool` | `false` | no |
| key\_expiration\_date | The expiration date for the Key Vault key | `string` | `"2028-12-31T23:59:59Z"` | no |
| key\_opts | List of key operations for Key Vault keys | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| key\_permissions | List of Key Vault key permissions | `list(string)` | <pre>[<br>  "Create",<br>  "Delete",<br>  "Get",<br>  "Purge",<br>  "Recover",<br>  "Update",<br>  "WrapKey",<br>  "UnwrapKey",<br>  "List",<br>  "Decrypt",<br>  "Sign"<br>]</pre> | no |
| key\_size | Size of the RSA key in bytes (e.g., 1024, 2048). | `number` | `2048` | no |
| key\_type | The Key Type for Key Vault. Possible values: EC, EC-HSM, RSA, RSA-HSM. Use an HSM key type only with a premium or HSM-capable Key Vault. | `string` | `"RSA"` | no |
| key\_vault\_id | The ID of the Key Vault for disk encryption. | `any` | `null` | no |
| key\_vault\_rbac\_auth\_enabled | Whether to use RBAC authorization for Key Vault instead of access policies. | `bool` | `true` | no |
| label\_order | The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']. | `list(any)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| license\_type | BYOL license type for Windows VMs. Possible values: Windows\_Client, Windows\_Server. | `string` | `"Windows_Client"` | no |
| linux\_patch\_mode | Mode of in-guest patching for Linux VMs. Possible values: AutomaticByPlatform, ImageDefault. | `string` | `"ImageDefault"` | no |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | `""` | no |
| log\_analytics\_destination\_type | Destination type for Log Analytics. Possible values: AzureDiagnostics, Dedicated. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | The ID of the Log Analytics Workspace for diagnostics. | `string` | `null` | no |
| maintenance\_configuration\_properties | A mapping of properties to assign to the maintenance configuration | `map(string)` | `{}` | no |
| maintenance\_configuration\_scope | The scope of the Maintenance Configuration. Possible values are Extension, Host, InGuestPatch, OSImage, SQLDB or SQLManagedInstance | `string` | `"Host"` | no |
| maintenance\_configuration\_visibility | The visibility of the Maintenance Configuration. Only allowable value is Custom | `string` | `"Custom"` | no |
| maintenance\_in\_guest\_user\_patch\_mode | The in guest user patch mode. Possible values are Platform or User. Must be specified when scope is InGuestPatch | `string` | `null` | no |
| maintenance\_install\_patches | Install patches configuration for InGuestPatch scope. Must be specified when scope is InGuestPatch | <pre>object({<br>    reboot = optional(string, "IfRequired")<br>    linux = optional(object({<br>      classifications_to_include    = optional(list(string))<br>      package_names_mask_to_exclude = optional(list(string))<br>      package_names_mask_to_include = optional(list(string))<br>    }))<br>    windows = optional(object({<br>      classifications_to_include = optional(list(string))<br>      kb_numbers_to_exclude      = optional(list(string))<br>      kb_numbers_to_include      = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| maintenance\_window | Maintenance window configuration block | <pre>object({<br>    start_date_time      = string<br>    expiration_date_time = optional(string)<br>    duration             = optional(string)<br>    time_zone            = string<br>    recur_every          = optional(string)<br>  })</pre> | `null` | no |
| managed | Specifies whether the availability set is managed (aligned) or classic. | `bool` | `true` | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| metric\_enabled | Whether diagnostic metrics are enabled. | `bool` | `true` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_interface\_sg\_enabled | Whether to attach a Network Security Group to the network interface. | `bool` | `true` | no |
| network\_security\_group\_id | The ID of the Network Security Group to attach to the Network Interface. | `string` | `""` | no |
| os\_disk\_storage\_account\_type | The Type of Storage Account for the OS Disk. Possible values: Standard\_LRS, StandardSSD\_LRS, Premium\_LRS. | `string` | `"StandardSSD_LRS"` | no |
| patch\_assessment\_mode | Mode of VM Guest Patching. Possible values: AutomaticByPlatform, ImageDefault. | `string` | `"ImageDefault"` | no |
| pip\_logs | Configuration for Public IP diagnostic logs. | <pre>object({<br>    enabled        = bool<br>    category       = optional(list(string))<br>    category_group = optional(list(string))<br>  })</pre> | <pre>{<br>  "category_group": [<br>    "AllLogs"<br>  ],<br>  "enabled": true<br>}</pre> | no |
| plan\_enabled | Whether to enable the marketplace image purchase plan. | `bool` | `false` | no |
| plan\_name | Specifies the name of the image from the marketplace. | `string` | `""` | no |
| plan\_product | Specifies the product of the marketplace image. | `string` | `""` | no |
| plan\_publisher | Specifies the publisher of the marketplace image. | `string` | `""` | no |
| platform\_fault\_domain\_count | Specifies the number of fault domains in the availability set. | `number` | `3` | no |
| platform\_update\_domain\_count | Specifies the number of update domains in the availability set. | `number` | `5` | no |
| primary | Is this the Primary IP Configuration? Must be true for the first ip\_configuration. | `bool` | `true` | no |
| private\_ip\_address\_allocation | The allocation method for the Private IP Address. Possible values: Dynamic, Static. | `string` | `"Static"` | no |
| private\_ip\_address\_version | The IP Version to use. Possible values: IPv4, IPv6. | `string` | `"IPv4"` | no |
| private\_ip\_addresses | List of Static IP Addresses to assign to the network interface. | `list(any)` | `[]` | no |
| provision\_vm\_agent | Should the Azure VM Agent be installed on the VM? | `bool` | `true` | no |
| proximity\_placement\_group\_id | The ID of the Proximity Placement Group to assign to the VM. | `string` | `null` | no |
| public\_ip\_enabled | Whether to create a public IP for the VM. | `bool` | `false` | no |
| public\_ip\_prefix\_id | ID of the public IP prefix resource to allocate the public IP from. | `string` | `null` | no |
| public\_key | SSH public key for authentication (e.g. `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQ`). | `string` | `null` | no |
| public\_network\_access\_enabled | Whether public network access is allowed for the VM. | `bool` | `false` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-virtual-machine"` | no |
| resource\_group\_name | The name of the resource group in which to create the Log Analytics. | `string` | n/a | yes |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "vnet-core-dev".<br>- If false, the keyword is appended: "core-dev-vnet".<br><br>This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| reverse\_fqdn | A fully qualified domain name that resolves to this public IP address. | `string` | `""` | no |
| shutdown\_schedule | Configuration for VM auto-shutdown schedule. Set to null to disable shutdown scheduling.<br><br>The daily\_recurrence\_time is in 24-hour format (e.g., "2000" for 8:00 PM).<br>Notification settings control pre-shutdown alerts via email and webhook.<br>Timezone should be specified as a valid IANA time zone identifier. | <pre>object({<br>    daily_recurrence_time = string<br>    notification_settings = object({<br>      enabled         = bool<br>      email           = string<br>      time_in_minutes = string<br>      webhook_url     = string<br>    })<br>    timezone = string<br>    enabled  = bool<br>    tags     = map(string)<br>  })</pre> | `null` | no |
| sku | The SKU of the Public IP. Possible values: Basic, Standard. | `string` | `"Basic"` | no |
| source\_image\_id | The ID of a custom Image to use for the VM. | `any` | `null` | no |
| storage\_account\_id | The ID of the Storage Account for diagnostic logs. | `string` | `null` | no |
| storage\_image\_reference\_enabled | Whether to use the platform image reference or a custom image. | `bool` | `true` | no |
| subnet\_id | Subnet ID for the private endpoint. | `string` | `null` | no |
| termination\_notification | Enable termination notification with ISO 8601 timeout (default: enabled=true, timeout=PT10M). | <pre>object({<br>    enabled = optional(bool, false)<br>    timeout = optional(string, "PT5M")<br>  })</pre> | <pre>{<br>  "enabled": true,<br>  "timeout": "PT10M"<br>}</pre> | no |
| timezone | Specifies the time zone of the VM. | `string` | `""` | no |
| ultra\_ssd\_enabled | Should Ultra SSD disks be enabled for this VM? | `bool` | `false` | no |
| user\_data | A string containing custom data/cloud-init script for the VM. | `string` | `null` | no |
| user\_object\_id | Map of Principal IDs and Role Definitions to assign in Key Vault. | <pre>map(object({<br>    role_definition_name = string<br>    principal_id         = string<br>  }))</pre> | `{}` | no |
| vault\_sku | The SKU of the Key Vault. Possible values: Standard, Premium. | `string` | `"Standard"` | no |
| vm\_availability\_zone | Specifies the Availability Zone in which this Virtual Machine should be located. | `any` | `null` | no |
| vm\_identity\_type | The Managed Service Identity Type. Possible values: SystemAssigned, UserAssigned. | `string` | `"SystemAssigned"` | no |
| vm\_size | Specifies the size of the Virtual Machine (e.g. Standard\_D2s\_v3). | `string` | `""` | no |
| windows\_patch\_mode | Mode of in-guest patching for Windows VMs. Possible values: Manual, AutomaticByOS, AutomaticByPlatform. | `string` | `"AutomaticByPlatform"` | no |
| winrm\_listeners | WinRM listener with protocol (Http/Https); certificate\_url needed if using Https (default: Http). | <pre>set(object({<br>    protocol        = string<br>    certificate_url = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "certificate_url": null,<br>    "protocol": "Http"<br>  }<br>]</pre> | no |
| write\_accelerator\_enabled | Specifies if Write Accelerator is enabled on the disk. Only for Premium\_LRS with no caching and M-Series VMs. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability\_set\_id | The ID of the Availability Set. |
| disk\_encryption\_set\_id | The ID of the Disk Encryption Set. |
| extension\_id | The ID of the Virtual Machine Extension. |
| ip\_configuration\_name | The name of the IP Configuration. |
| key\_id | ID of key that is used for disk encryption. |
| linux\_virtual\_machine\_id | The ID of the Linux Virtual Machine. |
| network\_interface\_id | The ID of the Network Interface. |
| network\_interface\_private\_ip\_addresses | The private IP addresses of the network interface. |
| network\_interface\_sg\_association\_id | The (Terraform specific) ID of the Association between the Network Interface and the Network Interface. |
| public\_ip\_address | The IP address value that was allocated. |
| public\_ip\_id | The Public IP ID. |
| service\_vault\_id | The Principal ID associated with this Managed Service Identity. |
| service\_vault\_tenant\_id | The Tenant ID associated with this Managed Service Identity. |
| vm\_backup\_policy\_id | The ID of the VM Backup Policy. |
| windows\_virtual\_machine\_id | The ID of the Windows Virtual Machine. |

