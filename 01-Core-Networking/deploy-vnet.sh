#!/bin/bash

# SECURITY NOTE: Do not hardcode passwords. 
# Run 'export VM_PASSWORD=YourSecurePassword' in your terminal before running this script.

# 1. Variables - Migrating to West US 2 to bypass capacity issues
MY_RG="Portfolio-Networking-West"
MY_LOC="westus2"
MY_VNET="Core-VNet"
MY_SUBNET="Server-Subnet"
VM_NAME="Web-Server-01"

echo "Step 1: Creating Resource Group in $MY_LOC..."
az group create --name $MY_RG --location $MY_LOC

echo "Step 2: Creating VNet and Subnet..."
az network vnet create \
  --resource-group $MY_RG \
  --name $MY_VNET \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $MY_SUBNET \
  --subnet-prefix 10.0.1.0/24 \
  --location $MY_LOC

echo "Step 3: Creating Network Security Group..."
az network nsg create \
  --resource-group $MY_RG \
  --name Server-NSG \
  --location $MY_LOC

echo "Step 4: Allowing SSH access on Port 22..."
az network nsg rule create \
  --resource-group $MY_RG \
  --nsg-name Server-NSG \
  --name AllowSSH \
  --protocol tcp \
  --priority 1000 \
  --destination-port-range 22 \
  --access allow

echo "Step 5: Linking NSG to Subnet..."
az network vnet subnet update \
  --resource-group $MY_RG \
  --vnet-name $MY_VNET \
  --name $MY_SUBNET \
  --network-security-group Server-NSG

# NOTE: Migrated to westus2 due to SKU availability and Quota restrictions in eastus.
# Used Standard_B2pts_v2 (ARM) and eventually Standard_D2s_v3 (Intel) to fit account limits.
# 6. Create the Intel-based VM (Using the most basic size)
echo "Step 6: Deploying the Server (D2s_v3)..."
az vm create \
  --resource-group $MY_RG \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --vnet-name $MY_VNET \
  --subnet $MY_SUBNET \
  --admin-username azureuser \
  --admin-password "$VM_PASSWORD" \
  --size Standard_D2s_v3 \
  --public-ip-sku Standard \
  --authentication-type password

  # Nnetwork Security configuration to enable port 80 for http
  az network nsg rule create \
  --resource-group Portfolio-Networking-West \
  --nsg-name Server-NSG \
  --name AllowHTTP \
  --protocol tcp \
  --priority 1010 \
  --destination-port-range 80 \
  --access allow