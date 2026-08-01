output "vnet_id" {
  value = azurerm_virtual_network.lab.id
}

output "subnet_id" {
  value = azurerm_subnet.lab.id
}

output "nsg_id" {
  value = azurerm_network_security_group.lab.id
}