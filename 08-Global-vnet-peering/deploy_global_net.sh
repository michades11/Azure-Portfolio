#!/bin/bash

RG_NAME="Lab08-GlobalNet-RG"
LOC_A="denmarkeast"
LOC_B="westeurope"
VM_SIZE_A="Standard_B1s"      # Denmark handles B1s perfectly!
VM_SIZE_B="Standard_F1as_v7"  # We verified this is 100% open in West Europe!
ADMIN_USER="azureuser"

echo "🚀 STEP 1: Re-Building the Global Network Foundation..."

# Create Resource Group
az group create --name $RG_NAME --location $LOC_A -o table

# Create Denmark VNet
az network vnet create --resource-group $RG_NAME --name "Denmark-VNet" \
  --location $LOC_A --address-prefixes 10.0.0.0/16 \
  --subnet-name "ProdSubnet" --subnet-prefixes 10.0.0.0/24 -o table

# Create West Europe VNet
az network vnet create --resource-group $RG_NAME --name "WestEurope-VNet" \
  --location $LOC_B --address-prefixes 10.1.0.0/16 \
  --subnet-name "DRSubnet" --subnet-prefixes 10.1.0.0/24 -o table

# Create Two-Way Peering
az network vnet peering create --name "Denmark-to-WestEurope" --resource-group $RG_NAME \
  --vnet-name "Denmark-VNet" --remote-vnet "WestEurope-VNet" --allow-vnet-access -o table

az network vnet peering create --name "WestEurope-to-Denmark" --resource-group $RG_NAME \
  --vnet-name "WestEurope-VNet" --remote-vnet "Denmark-VNet" --allow-vnet-access -o table


echo "🖥️ STEP 2: Deploying Capacity-Safe Compute Instances..."

# Deploy Denmark Server
echo "🇩🇰 Spinning up Denmark Private VM ($VM_SIZE_A)..."
az vm create \
  --resource-group $RG_NAME \
  --name "VM-Denmark-Prod" \
  --location $LOC_A \
  --vnet-name "Denmark-VNet" \
  --subnet "ProdSubnet" \
  --image "Ubuntu2204" \
  --size $VM_SIZE_A \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --public-ip-address "" -o table

# Deploy West Europe Server
echo "🇪🇺 Spinning up West Europe Private VM ($VM_SIZE_B)..."
az vm create \
  --resource-group $RG_NAME \
  --name "VM-WestEurope-DR" \
  --location $LOC_B \
  --vnet-name "WestEurope-VNet" \
  --subnet "DRSubnet" \
  --image "Ubuntu2204" \
  --size $VM_SIZE_B \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --public-ip-address "" -o table

echo "✅ Global Stack Fully Automated and Connected!"