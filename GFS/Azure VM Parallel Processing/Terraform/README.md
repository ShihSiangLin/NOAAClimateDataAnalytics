# Terraform - Create and configure Linux Virtual Machine Scale Set in Azure

1. Install terraform
2. Add terraform.exe to environment path
3. cd to directory where .tf files are stored

## Create SSH key pair (RSA) in terminal:

```
cd ~/.ssh
ssh-keygen -b 2048 -t rsa -f fcapssh
```

## Initialize Terraform
```
terraform init -upgrade 
```
## Create a Terraform execution plan
```
terraform plan -out main.tfplan 
```
## Apply a Terraform execution plan
```
terraform apply main.tfplan
```
## Create a Terraform destroy plan
```
terraform plan -destroy -out main.destroy.tfplan
```
## Apply a Terraform destroy plan
```
terraform apply main.destroy.tfplan
```
---

## Note
- In `providers.tf`, replace the `subscription_id` with yours.
- In `main.tf`, under `resource "azurerm_linux_virtual_machine_scale_set"`, change the variable `instances` to your desire. It is now defaulted to `24`. 
- In `variables.tf`, change the variable `vm_size` to your desire. It is now defaulted to `Standard_E2ads_v5`.
- [This file](./vmss_config.sh) is used to configure the environment in each virtual instances. 
- Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set
