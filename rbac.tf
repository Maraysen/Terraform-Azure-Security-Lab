resource "azurerm_role_assignment" "webapp_key_vault_secrets_user" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.lab.identity[0].principal_id
}

resource "azurerm_role_assignment" "current_user_secrets_officer" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}