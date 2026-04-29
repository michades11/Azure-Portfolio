#!/bin/bash

# 1. Variables
RG_NAME="Lab02-Automation-RG"
LOCATION="westus2"
VM_NAME="Auto-Server-01"

# 2. Create Resource Group
echo "Creating Resource Group..."
az group create --name $RG_NAME --location $LOCATION

# 3. Create VM with Automation and Extra Storage
echo "Deploying VM with 10GB Data Disk and Cloud-Init..."
az vm create \
  --resource-group $RG_NAME \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-username seyiadmin \
  --admin-password "$VM_PASSWORD" \
  --custom-data cloud-init.txt \
  --data-disk-sizes-gb 10 \
  --public-ip-sku Standard \
  --location $LOCATION

# 4. Open Port 80 (Shortened command)
echo "Opening Port 80..."
az vm open-port --port 80 --resource-group $RG_NAME --name $VM_NAME --priority 1010   