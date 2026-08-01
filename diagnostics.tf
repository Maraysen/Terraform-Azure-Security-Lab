locals {
  web_app_log_categories = toset([
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs",
    "AppServiceAuthenticationLogs"
  ])
}

resource "azurerm_monitor_diagnostic_setting" "web_app" {
  name                       = "diag-webapp-to-law"
  target_resource_id         = azurerm_linux_web_app.lab.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id

  dynamic "enabled_log" {
    for_each = local.web_app_log_categories

    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
