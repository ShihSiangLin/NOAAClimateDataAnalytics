# Using Azure CLI to manage Virtual Machines / Virtual Machines Scale Sets

## Install and configure the Azure CLI
### 1. Install Azure Cloud Shell
- [See here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for instructions to install the Azure CLI.
- After installing, run the following command to see the version of Azure CLI.
    ```
    az version
    ```
### 2. Sign into the Azure CLI
- Run the following command to login.
    ```
    az login
    ```
- Sign in with your account credentials in the browser.

## Commands to start and stop (deallocate) virtual machines
### 1. Virtual Machines:
- To start it, run the following command
    ```
    az vm start -g <your_resource_group_name> -n <your_virtual_machine_name> --verbose
    ```
- To stop(deallocate) it, run the following command
    ```
    az vm deallocate -g <your_resource_group_name> -n <your_virtual_machine_name> --verbose
    ```
### 2. Virtual Machine Scale Sets:
- To start it, run the following command
    ```
    az vmss start -g <your_resource_group_name> -n <your_virtual_machine_scale_sets_name> --verbose
    ```
- To stop(deallocate) it, run the following command
    ```
    az vmss deallocate -g <your_resource_group_name> -n <your_virtual_machine_scale_sets_name> --verbose
    ```