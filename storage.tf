resource "azurerm_storage_account" "lab" {
  name                     = "sttfsecuritymk26"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # checkov:skip=CKV2_AZURE_41:SAS expiration policy is explicitly configured; Checkov does not recognise the current AzureRM syntax.
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Log"
  }


  tags = var.common_tags
}

resource "azurerm_storage_account" "backup" {
  count = var.create_backup_storage ? 1 : 0

  name                     = "stbackupmk26"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  # checkov:skip=CKV2_AZURE_41:SAS expiration policy is explicitly configured; Checkov does not recognise the current AzureRM syntax.
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Log"
  }


  tags = var.common_tags
}