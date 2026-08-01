terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate57304126"
    container_name       = "tfstate"
    key                  = "azure-security-lab.tfstate"
    use_azuread_auth     = true
  }
}