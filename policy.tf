data "azurerm_policy_definition_built_in" "allowed_locations" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allow Australia East only"
  resource_group_id    = azurerm_resource_group.lab.id
  policy_definition_id = data.azurerm_policy_definition_built_in.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "australiaeast"
      ]
    }
  })
}