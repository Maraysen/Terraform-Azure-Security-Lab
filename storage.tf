resource "azurerm_storage_account" "lab" {
  # checkov:skip=CKV2_AZURE_33:Private endpoints are outside the current lab scope; storage hardening is handled with TLS, disabled public blobs, disabled shared keys and SAS expiry.
  # checkov:skip=CKV_AZURE_206:LRS is intentionally used to keep this non-production lab low cost.
  # checkov:skip=CKV_AZURE_59:Public network access remains enabled because private endpoints are outside this lab scope.
  # checkov:skip=CKV_AZURE_33:Queue service logging is outside scope because this lab does not use Azure Queue Storage. name                     = "sttfsecuritymk26"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # checkov:skip=CKV2_AZURE_41:SAS expiration policy is explicitly configured; Checkov does not recognise the current AzureRM syntax.
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Log"
  }


  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.common_tags
}

resource "azurerm_storage_account" "backup" {
  # checkov:skip=CKV2_AZURE_33:Private endpoints are outside the current lab scope; storage hardening is handled with TLS, disabled public blobs, disabled shared keys and SAS expiry.
  count = var.create_backup_storage ? 1 : 0

  name                     = "stbackupmk26"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  # checkov:skip=CKV2_AZURE_41:SAS expiration policy is explicitly configured; Checkov does not recognise the current AzureRM syntax.
  sas_policy {
    expiration_period = "1.00:00:00"
    expiration_action = "Log"
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }


  tags = var.common_tags
}