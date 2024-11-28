output "resource_group_name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name_1" {
  description = "The name of the first created virtual network."
  value       = azurerm_virtual_network.my_terraform_network_1.name
}

output "virtual_network_name_2" {
  description = "The name of the second created virtual network."
  value       = azurerm_virtual_network.my_terraform_network_2.name
}

output "subnet_name_1" {
  description = "The name of the created subnet 1."
  value       = azurerm_subnet.my_terraform_subnet_1.name
}

output "subnet_name_2" {
  description = "The name of the created subnet 2."
  value       = azurerm_subnet.my_terraform_subnet_2.name
}