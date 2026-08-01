resource "azurerm_resource_group" "import_demo" {
  name     = "rg-terraform-import-demo"
  location = "australiaeast"

  tags = {
    purpose = "import-demo"
  }
}