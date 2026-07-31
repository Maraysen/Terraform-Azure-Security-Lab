terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}


provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "lab" {
  name     = "rg-terraform-security-lab"
  location = "Australia East"
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "lab" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.20.1.0/24"]
}



resource "azurerm_network_security_group" "lab" {
  name                = "nsg-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "lab" {
  name                       = "kvtfsecuritymk26"
  location                   = azurerm_resource_group.lab.location
  resource_group_name        = azurerm_resource_group.lab.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "kv-to-log-analytics"
  target_resource_id         = azurerm_key_vault.lab.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id

  enabled_log {
    category = "AuditEvent"
  }
}

resource "azurerm_service_plan" "lab" {
  name                = "asp-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "lab" {
  name                = "webapp-terraform-security-mk26"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.lab.id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    LabSecret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.lab.id})"
  }

  site_config {
    always_on = false
  }
}

resource "azurerm_role_assignment" "webapp_key_vault_secrets_user" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.lab.identity[0].principal_id
}

resource "azurerm_key_vault_secret" "lab" {
  name         = "Lab-Test-Secret"
  value        = "TerraformTest123"
  key_vault_id = azurerm_key_vault.lab.id
}

resource "azurerm_role_assignment" "current_user_secrets_officer" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}