variable "location" {
  default     = "eastus"
  description = "Location where resources will be created"
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureadmin"
}

variable "admin_password" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "Test1234!"
}

variable "vm_size" {
  description = "The size for the VM being created."
  type        = string
  default     = "Standard_E2ads_v5"
}