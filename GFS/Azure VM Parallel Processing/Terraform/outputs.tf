output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}

output "vmss_private_ip" {
  value = data.azurerm_virtual_machine_scale_set.example.instances.*.private_ip_address
}