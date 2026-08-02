variable "location" {
  description = "Azure region for the lab resources"
  type        = string
  default     = "Australia East"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-terraform-security-lab"
}

variable "common_tags" {
  description = "Standard tags applied to Azure lab resources"
  type        = map(string)


  default = {
    Environment = "Lab"
    Project     = "Terraform-Azure-Security"
    ManagedBy   = "Terraform"
  }
}

variable "lab_secret" {
  description = "Test secret stored in Azure Key Vault"
  type        = string
  sensitive   = true


}

variable "create_backup_storage" {
  description = "Create an additional backup storage account"
  type        = bool
  default     = false
}