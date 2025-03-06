# Create resource group
resource "azurerm_resource_group" "vmss" {
  name     = "FCAP-${var.vm_size}"
  location = var.location
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_virtual_network" "vmss" {
  name                = "vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
}

resource "azurerm_subnet" "vmss" {
  name                 = "vmss-subnet"
  resource_group_name  = azurerm_resource_group.vmss.name
  virtual_network_name = azurerm_virtual_network.vmss.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vmss" {
  name                = "vmss-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
}

resource "azurerm_lb" "vmss" {
  name                = "vmss-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id     = azurerm_lb.vmss.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "vmscaleset"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  sku                 = var.vm_size
  instances           = 24
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  disable_password_authentication = false
  upgrade_mode  =  "Automatic"

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_5"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    caching = "ReadWrite"
    disk_size_gb = 25
    lun = 10
    storage_account_type = "Standard_LRS"
  }

  network_interface  {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.vmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "example" {
  depends_on = [null_resource.example]
  name                         = "example"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("vmss_config.sh")}"
    }
  SETTINGS
}


data "azurerm_virtual_machine_scale_set" "example" {
  depends_on = [azurerm_linux_virtual_machine_scale_set.vmss]
  name                = azurerm_linux_virtual_machine_scale_set.vmss.name
  resource_group_name = azurerm_resource_group.vmss.name
}

#--------------------------------------------------------------------------------

resource "azurerm_public_ip" "jumpbox" {
  name                = "jumpbox-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  domain_name_label   = "${random_string.fqdn.result}-ssh"
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.vmss.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.vmss.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "jumpbox"
  location              = var.location
  resource_group_name   = azurerm_resource_group.vmss.name
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  size                  = var.vm_size

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8_5"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.admin_user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_user
    public_key = file("~/.ssh/fcapssh.pub")
  }
}

resource "azurerm_managed_disk" "example1" {
  depends_on = [azurerm_linux_virtual_machine.my_terraform_vm]
  name                 = "myVM-disk"
  location             = var.location
  resource_group_name  = azurerm_resource_group.vmss.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 25
}

resource "azurerm_virtual_machine_data_disk_attachment" "example1" {
  depends_on = [azurerm_managed_disk.example1]
  managed_disk_id    = azurerm_managed_disk.example1.id
  virtual_machine_id = azurerm_linux_virtual_machine.my_terraform_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

locals {
  depends_on = [data.azurerm_virtual_machine_scale_set.example]
  params = join(",", data.azurerm_virtual_machine_scale_set.example.instances.*.private_ip_address)
}

resource "null_resource" "example" {
  depends_on = [azurerm_virtual_machine_data_disk_attachment.example1, data.azurerm_virtual_machine_scale_set.example]
  
  connection {
    type     = "ssh"
    user     =  var.admin_user
    private_key  = file("~/.ssh/fcapssh")
    host     = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
    agent    = false
    timeout  = "4m"
  }

  # upload local folder to VM
  provisioner "file" {
    source      = "~/fewxops"
    destination = "/tmp"
  }

  # execute vmconfig shell script in VM
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/fewxops/software/jumpbox_config.sh",
        "sudo /tmp/fewxops/software/jumpbox_config.sh ${local.params}"
    ]
  }
}

resource "local_file" "vm_ip_file" {
  depends_on = [ azurerm_linux_virtual_machine.my_terraform_vm ]
  content = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
  filename = "vm_ip.txt"
}