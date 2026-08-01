module "network" {
  source = "./modules/network"

  vnet_name               = "vnet-terraform-security-lab"
  location                = azurerm_resource_group.lab.location
  resource_group_name     = azurerm_resource_group.lab.name
  vnet_address_space      = ["10.20.0.0/16"]
  subnet_name             = "snet-app"
  subnet_address_prefixes = ["10.20.1.0/24"]
  nsg_name                = "nsg-terraform-security-lab"
  tags                    = var.common_tags
}