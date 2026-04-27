#!/bin/bash

# --- VARIABLES ---
# Think of these as your "Label Maker"
MY_RG="01-Networking-Lab"
MY_LOC="northeurope"       # This is Ireland - best for Nigeria
MY_VNET="Core-VNet"
MY_SUBNET="Server-Subnet"

# 1. Create the Resource Group (The "Rack")
echo "Creating Resource Group..."
az group create --name $MY_RG --location $MY_LOC

# 2. Create the Virtual Network & Subnet (The "Switch & VLAN")
echo "Creating VNet and Subnet..."
az network vnet create \
  --name $MY_VNET \
  --resource-group $MY_RG \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $MY_SUBNET \
  --subnet-prefix 10.0.1.0/24


  # 3. Create the NSG (The "Firewall")
echo "Creating the Network Security Group..."
az network nsg create \
  --name Server-NSG \
  --resource-group $MY_RG

# 4. Create an ACL Rule to allow SSH (Port 22)
echo "Allowing SSH access on Port 22..."
az network nsg rule create \
  --name AllowSSH \
  --nsg-name Server-NSG \
  --priority 100 \
  --resource-group $MY_RG \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22
  

  # 5. Link the Firewall to the Subnet (The "Connection")
echo "Plugging the NSG into the Subnet..."
az network vnet subnet update \
  --name $MY_SUBNET \
  --vnet-name $MY_VNET \
  --resource-group $MY_RG \
  --network-security-group Server-NSG