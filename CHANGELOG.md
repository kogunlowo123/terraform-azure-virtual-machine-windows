# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- Initial release of the Azure Windows Virtual Machine Terraform module
- Windows VM with configurable size, image, and OS disk settings
- Automatic NIC creation with optional public IP address
- Multiple managed data disk support with configurable storage types and caching
- Availability set and availability zone placement
- Proximity placement group support
- Microsoft Antimalware extension with configurable scan settings and exclusions
- Azure Monitor Agent extension for monitoring
- Azure AD Login extension for AAD-based authentication
- Custom VM extension support
- Boot diagnostics with managed or custom storage account
- Managed identity support (SystemAssigned and UserAssigned)
- Azure Backup integration with Recovery Services Vault
- Trusted Launch support (Secure Boot and vTPM)
- Host-level encryption support
- Azure Hybrid Benefit licensing support
- WinRM listener configuration
- Configurable patching mode and assessment
- Comprehensive examples: basic, advanced, and complete
