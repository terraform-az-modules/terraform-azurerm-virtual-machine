<!-- BEGIN_TF_DOCS -->

# Azure Virtual Machine 

This example provisions a Virtual Machine in Azure a using the `terraform-azure-virtual-machine` module.


---

## ✅ Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0 |

---

## 🔌 Providers

_No providers are explicitly defined in this example._

---

## 📦 Modules

| Name               | Source                                                                                | Version |
| ------------------ | ------------------------------------------------------------------------------------- | ------- |
| `resource_group`   | terraform-az-modules/resource-group/azure                                             | 1.0.0   |
| `vnet`             | terraform-az-modules/vnet/azure                                                       | 1.0.0   |
| `subnet`           | terraform-az-modules/subnet/azure                                                     | 1.0.0   |
| `security_group`   | terraform-az-modules/nsg/azure                                                        | 1.0.0   |
| `log-analytics`    | terraform-az-modules/log-analytics/azure                                              | 1.0.0   |
| `key_vault`        | terraform-az-modules/key-vault/azure                                                  | 1.0.0   |
| `private_dns_zone` | terraform-az-modules/private-dns/azure                                                | 1.0.0   |
| `virtual-machine`  | `../../`                                                                              | n/a     |


---

## 🏗️ Resources

_No standalone resources are declared in this example._

---

## 🔧 Inputs

_No input variables are defined in this example._

---

## 📤 Outputs

| Name                              | Description                                             |
|-----------------------------------|---------------------------------------------------------|
| `availability_set_id`             | The ID of the Availability Set.                         |
| `network_interface_private_ip_addresses` | The private IP addresses of the network interface. |
| `public_ip_address`               | The IP address value that was allocated.                |
| `public_ip_id`                    | The Public IP ID.                                       |
| `virtual_machine_id`              | The ID of the Virtual Machine.                          |

<!-- END_TF_DOCS -->
