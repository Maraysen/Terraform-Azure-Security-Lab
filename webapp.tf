resource "azurerm_service_plan" "lab" {
  # checkov:skip=CKV_AZURE_211:This is a non-production learning lab using the free F1 tier.
  # checkov:skip=CKV_AZURE_212:Multiple instances and failover are outside the scope of this learning lab.
  # checkov:skip=CKV_AZURE_225:Zone redundancy requires a production-grade paid tier and is outside this lab scope.

  name                = "asp-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  os_type             = "Linux"
  sku_name            = "F1"
  tags                = var.common_tags
}

resource "azurerm_linux_web_app" "lab" {

  # checkov:skip=CKV_AZURE_214:Always On is unavailable on the free F1 tier.
  # checkov:skip=CKV_AZURE_88:Azure Files storage is not required by this stateless learning app.
  # checkov:skip=CKV_AZURE_17:Mutual TLS client certificates are outside this lab scope.
  # checkov:skip=CKV_AZURE_213:The lab has no deployed application health endpoint.
  # checkov:skip=CKV_AZURE_13:App Service Authentication is outside this infrastructure pipeline lab scope.
  # checkov:skip=CKV_AZURE_222:Private web-app access requires private networking, which is outside this lab scope.

  name                = "webapp-terraform-security-mk26"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  service_plan_id     = azurerm_service_plan.lab.id
  tags                = var.common_tags

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    LabSecret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.lab.id})"
  }

  site_config {
    always_on     = false
    ftps_state    = "Disabled"
    http2_enabled = true
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }


}