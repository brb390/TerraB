output "network" {
value = azurerm_virtual_network.net1.name
}
output "subnet" {
value = azurerm_subnet.subnet1.address_prefixes
}
output "security_group_protocol_open" {
value = azurerm_network_security_rule.http.protocol
}
output "allocation_IP" {
value = azurerm_public_ip.publicip[*].ip_address
}
output "Creation_NIC" {
value = azurerm_network_interface.networkinterface[*].name
}
output "Utilisateur_de_la_connexion" {
value = azurerm_linux_virtual_machine.VM[*].admin_username  
}