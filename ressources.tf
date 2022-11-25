resource "azurerm_resource_group" "terraform" {
   name     = var.resource_group_name
   location = var.location
}

 resource "azurerm_virtual_network" "net1" {
   name                = var.reseau
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.terraform.location
   resource_group_name = azurerm_resource_group.terraform.name
}

 resource "azurerm_subnet" "subnet1" {
   name                = var.subnet
   address_prefixes    = var.subnet_cidr
   virtual_network_name = azurerm_virtual_network.net1.name
   resource_group_name = azurerm_resource_group.terraform.name
}

resource "azurerm_network_security_group" "linux-vm-nsg" {
  depends_on=[azurerm_virtual_network.net1]
  name                = "linux-vm-nsg"
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
}  

resource "azurerm_network_security_rule" "ssh" {
    resource_group_name         = azurerm_resource_group.terraform.name
    network_security_group_name = azurerm_network_security_group.linux-vm-nsg.name
    name                       = "AllowSSH"
    description                = "Allow SSH"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "http" {
    resource_group_name         = azurerm_resource_group.terraform.name
    network_security_group_name = azurerm_network_security_group.linux-vm-nsg.name
    name                       = "AllowHTTP"
    description                = "Allow HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
}

resource "azurerm_subnet_network_security_group_association" "linux-vm-nsg-association" {
    depends_on                 = [azurerm_virtual_network.net1,azurerm_network_security_group.linux-vm-nsg]
    subnet_id                  = azurerm_subnet.subnet1.id
    network_security_group_id  = azurerm_network_security_group.linux-vm-nsg.id
}

resource "azurerm_public_ip" "publicip" {
  depends_on=[azurerm_subnet.subnet1]
  name                = "IP${count.index}"
  count               = var.nombre_de_IP
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "networkinterface" {
  depends_on=[azurerm_subnet.subnet1]
  name                = "NIC${count.index}"
  count               = var.nombre_de_NIC
  location            = azurerm_resource_group.terraform.location
  resource_group_name = azurerm_resource_group.terraform.name
    ip_configuration {
    name                          = "interne"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

/* resource "azurerm_ssh_public_key" "sshkey" {
  name                = "sshkey"
  resource_group_name = azurerm_resource_group.terraform.name
  location            = "Australia East"
  public_key          = file("~/.ssh/id_rsa.pub")
}*/

resource "azurerm_linux_virtual_machine" "VM" {
  name                = "VM${count.index}"
  count               = var.nombre_de_vm
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [element(azurerm_network_interface.networkinterface.*.id, count.index)]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.source_image[0]
    offer     = var.source_image[1]
    sku       = var.source_image[2]
    version   = var.source_image[3]
  }
}