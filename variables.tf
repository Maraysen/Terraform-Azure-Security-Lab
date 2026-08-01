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
  description = "Standard tags applied to supported resources"
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