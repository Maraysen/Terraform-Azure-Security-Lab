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