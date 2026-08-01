output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "web_app_hostname" {
  value = azurerm_linux_web_app.lab.default_hostname
}

output "key_vault_name" {
  value = azurerm_key_vault.lab.name
}