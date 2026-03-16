variable "name" {
  description = "The name of the Windows Virtual Machine."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name))
    error_message = "VM name must be 1-15 characters, containing only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region for the VM."
  type        = string
}

variable "size" {
  description = "The SKU size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "The administrator username for the VM."
  type        = string

  validation {
    condition     = !contains(["administrator", "admin", "user", "user1", "test", "guest", "root"], lower(var.admin_username))
    error_message = "Admin username cannot be a reserved name like administrator, admin, user, root, etc."
  }
}

variable "admin_password" {
  description = "The administrator password for the VM."
  type        = string
  sensitive   = true
}

variable "network_interface_ids" {
  description = "List of network interface IDs to attach. If empty, a NIC will be created."
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "The subnet ID for the auto-created NIC (required if network_interface_ids is empty)."
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "The allocation method for the private IP (Dynamic or Static)."
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be Dynamic or Static."
  }
}

variable "private_ip_address" {
  description = "The static private IP address (only used when allocation is Static)."
  type        = string
  default     = null
}

variable "create_public_ip" {
  description = "Whether to create a public IP address for the VM."
  type        = bool
  default     = false
}

variable "public_ip_sku" {
  description = "The SKU of the public IP (Basic or Standard)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be Basic or Standard."
  }
}

variable "source_image_reference" {
  description = "The source image reference for the VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "The ID of a custom image to use (overrides source_image_reference if set)."
  type        = string
  default     = null
}

variable "os_disk" {
  description = "OS disk configuration."
  type = object({
    caching                          = optional(string, "ReadWrite")
    storage_account_type             = optional(string, "Premium_LRS")
    disk_size_gb                     = optional(number, null)
    disk_encryption_set_id           = optional(string, null)
    write_accelerator_enabled        = optional(bool, false)
    security_encryption_type         = optional(string, null)
    secure_vm_disk_encryption_set_id = optional(string, null)
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

variable "data_disks" {
  description = "Map of managed data disks to create and attach."
  type = map(object({
    storage_account_type   = optional(string, "Premium_LRS")
    disk_size_gb           = number
    create_option          = optional(string, "Empty")
    caching                = optional(string, "ReadOnly")
    lun                    = number
    disk_encryption_set_id = optional(string, null)
    tier                   = optional(string, null)
    zone                   = optional(string, null)
  }))
  default = {}
}

variable "zone" {
  description = "The availability zone for the VM (1, 2, or 3)."
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || contains(["1", "2", "3"], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}

variable "availability_set_id" {
  description = "The ID of the availability set (cannot be used with zones)."
  type        = string
  default     = null
}

variable "proximity_placement_group_id" {
  description = "The ID of the proximity placement group."
  type        = string
  default     = null
}

variable "license_type" {
  description = "The license type for the VM (None, Windows_Client, or Windows_Server)."
  type        = string
  default     = null

  validation {
    condition     = var.license_type == null || contains(["None", "Windows_Client", "Windows_Server"], var.license_type)
    error_message = "License type must be None, Windows_Client, or Windows_Server."
  }
}

variable "enable_automatic_updates" {
  description = "Whether automatic updates are enabled."
  type        = bool
  default     = true
}

variable "patch_mode" {
  description = "The patching mode (Manual, AutomaticByOS, or AutomaticByPlatform)."
  type        = string
  default     = "AutomaticByOS"

  validation {
    condition     = contains(["Manual", "AutomaticByOS", "AutomaticByPlatform"], var.patch_mode)
    error_message = "Patch mode must be Manual, AutomaticByOS, or AutomaticByPlatform."
  }
}

variable "patch_assessment_mode" {
  description = "The patch assessment mode (AutomaticByPlatform or ImageDefault)."
  type        = string
  default     = "ImageDefault"

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_assessment_mode)
    error_message = "Patch assessment mode must be AutomaticByPlatform or ImageDefault."
  }
}

variable "hotpatching_enabled" {
  description = "Whether hotpatching is enabled."
  type        = bool
  default     = false
}

variable "timezone" {
  description = "The time zone for the VM (e.g., 'Eastern Standard Time')."
  type        = string
  default     = null
}

variable "provision_vm_agent" {
  description = "Whether the Azure VM Agent is provisioned."
  type        = bool
  default     = true
}

variable "encryption_at_host_enabled" {
  description = "Whether encryption at host is enabled."
  type        = bool
  default     = false
}

variable "secure_boot_enabled" {
  description = "Whether secure boot is enabled (Trusted Launch)."
  type        = bool
  default     = false
}

variable "vtpm_enabled" {
  description = "Whether vTPM is enabled (Trusted Launch)."
  type        = bool
  default     = false
}

variable "allow_extension_operations" {
  description = "Whether extension operations are allowed."
  type        = bool
  default     = true
}

variable "computer_name" {
  description = "The computer name for the VM (defaults to the VM name)."
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Base64-encoded custom data for the VM."
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64-encoded user data for the VM."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "The type of managed identity (SystemAssigned, UserAssigned, or both)."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "A list of user-assigned managed identity IDs."
  type        = list(string)
  default     = []
}

variable "boot_diagnostics_storage_account_uri" {
  description = "The storage account URI for boot diagnostics (null for managed storage)."
  type        = string
  default     = null
}

variable "enable_boot_diagnostics" {
  description = "Whether to enable boot diagnostics."
  type        = bool
  default     = false
}

variable "winrm_listeners" {
  description = "WinRM listener configurations."
  type = list(object({
    protocol        = string
    certificate_url = optional(string, null)
  }))
  default = []
}

variable "additional_unattend_content" {
  description = "Additional unattend content for the VM."
  type = list(object({
    setting = string
    content = string
  }))
  default = []
}

variable "enable_antimalware_extension" {
  description = "Whether to install the Microsoft Antimalware extension."
  type        = bool
  default     = false
}

variable "antimalware_settings" {
  description = "Microsoft Antimalware extension settings."
  type = object({
    real_time_protection_enabled = optional(bool, true)
    scheduled_scan_enabled       = optional(bool, true)
    scheduled_scan_type          = optional(string, "Quick")
    scheduled_scan_day           = optional(number, 7)
    scheduled_scan_time          = optional(number, 120)
    exclusions_extensions        = optional(string, "")
    exclusions_paths             = optional(string, "")
    exclusions_processes         = optional(string, "")
  })
  default = {}
}

variable "enable_monitoring_extension" {
  description = "Whether to install the Azure Monitor Agent extension."
  type        = bool
  default     = false
}

variable "enable_azure_ad_login" {
  description = "Whether to enable Azure AD login extension."
  type        = bool
  default     = false
}

variable "custom_extensions" {
  description = "Map of custom VM extensions to install."
  type = map(object({
    publisher                  = string
    type                       = string
    type_handler_version       = string
    auto_upgrade_minor_version = optional(bool, true)
    automatic_upgrade_enabled  = optional(bool, false)
    settings                   = optional(string, null)
    protected_settings         = optional(string, null)
  }))
  default = {}
}

variable "backup_policy_id" {
  description = "The ID of the backup policy to associate with the VM."
  type        = string
  default     = null
}

variable "recovery_vault_name" {
  description = "The name of the Recovery Services Vault for backup."
  type        = string
  default     = null
}

variable "backup_resource_group_name" {
  description = "The resource group of the Recovery Services Vault (defaults to the VM resource group)."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
