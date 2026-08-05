resource "azurerm_role_assignment" "webapp_key_vault_secrets_user" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.lab.identity[0].principal_id
}

resource "azurerm_role_assignment" "current_user_secrets_officer" {
  scope                = azurerm_key_vault.lab.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "fe193dee-1dbf-4026-b99d-3b4c16d5e307"
}