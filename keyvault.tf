resource "azurerm_key_vault" "lab" {
  name                       = "kvtfsecuritymk26"
  location                   = azurerm_resource_group.lab.location
  resource_group_name        = azurerm_resource_group.lab.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_key_vault_secret" "lab" {
  name            = "Lab-Test-Secret"
  value           = var.lab_secret
  key_vault_id    = azurerm_key_vault.lab.id
  content_type    = "Lab application secret"
  expiration_date = "2027-08-05T00:00:00Z"
  tags            = var.common_tags
}