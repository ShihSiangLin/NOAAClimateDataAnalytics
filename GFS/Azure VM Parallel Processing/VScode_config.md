# Connect VS code to Azure VM
## 1. Add SSH key to VM:
- Install `Azure Resources` in VScode extension
- Sign in to the Azure Subscription
- Right click the VM just created and click `Add SSH Key...` to add `fcapssh` public key

## 2. Get connected:
- Install `Remote-SSH: Connect to host` in VScode extension
- Under `Azure Resources - Virtual machines`, right click the VM just created and hit `Connect to Host via Remote SSH` and get connected.