variable "resource_group_name" {
description = "Name of the environment"
default = "terraform"
}
variable "location" {
description = "Azure location to use"
default = "AustraliaEast"
}
variable "reseau" {
description = "Azure network to use"
default = "net1"
}
variable "subnet" {
description = "Azure Subnet to use"
default = "subnet1"
}
variable "subnet_cidr" {
description = "Subnet CIDR"
default = ["10.0.0.0/24"]
}
variable "nsg_name" {
description = "Nom du nsg"
default = "NSG_Terraform"
}
variable "default_user_name" {
description = "Name of the default user"
default = "adminuser"
}
variable "source_image" {
description = "les sources de l image"
default =  ["Canonical","UbuntuServer","16.04-LTS","latest"]
}
variable "nombre_de_vm" {
description = "Le nombre de VM"
default = 1
}
variable "nombre_de_IP" {
description = "Le nombre de IP"
default = 1
}
variable "nombre_de_NIC" {
description = "Le nombre de NIC"
default = 1
}