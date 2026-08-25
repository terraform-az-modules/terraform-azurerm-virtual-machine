# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.3.0] - 2026-08-25
### :bug: Bug Fixes
- [`95f487a`](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/commit/95f487a1341c23553206fff72a22b89959c1a542) - fixed stf checks and remove path filter *(PR [#28](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/pull/28) by [@karan-cd](https://github.com/karan-cd))*


## [v1.2.0] - 2026-06-19
### :bug: Bug Fixes
- [`338d666`](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/commit/338d666745cbe0c8598a72eb12826caebc1ec9ab) - default disk encryption key type to RSA *(PR [#25](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/pull/25) by [@dverma-cd](https://github.com/dverma-cd))*
- [`cecf673`](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/commit/cecf6736411512cfab19904259ea0dc4b314eda4) - public ip standard sku *(PR [#26](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/pull/26) by [@asharma-cd](https://github.com/asharma-cd))*

### :wrench: Chores
- [`f91184d`](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/commit/f91184dc7c9b9df58e6702dd7e54651f2b296813) - **deps**: bump actions/checkout from 3 to 6 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*
- [`abb2e2c`](https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/commit/abb2e2cce1f33f003757c5289f1ce8342699c017) - **deps**: bump actions/checkout from 6 to 7 *(commit by [@dependabot[bot]](https://github.com/apps/dependabot))*


## [1.1.1] - 2026-03-20

### Changes
- Add provider_meta for API usage tracking
- Add terraform tests and pre-commit CI workflow
- Add SECURITY.md, CONTRIBUTING.md, .releaserc.json
- Standardize pre-commit to antonbabenko v1.105.0
- Set provider: none in tf-checks for validate-only CI
- Bump required_version to >= 1.10.0
[v1.2.0]: https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/compare/v1.1.2...v1.2.0
[v1.3.0]: https://github.com/terraform-az-modules/terraform-azurerm-virtual-machine/compare/v1.2.0...v1.3.0
