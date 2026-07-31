resource "azurerm_log_analytics_workspace" "lab" {
  name                = "law-terraform-security-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "kv-to-log-analytics"
  target_resource_id         = azurerm_key_vault.lab.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id

  enabled_log {
    category = "AuditEvent"
  }
}