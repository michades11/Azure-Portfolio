#!/bin/bash

# --- 1. SETTINGS (The Ingredients) ---
# We use variables so if we want to change the location later, 
# we only change it in one place!
RG_NAME="Lab05-Secure-RG"
LOCATION="eastus"
VNET_NAME="SecureVNet"

# We are splitting our network into two "rooms"
FRONTEND_SUBNET="WebSubnet"
BACKEND_SUBNET="DBSubnet"

# IP Addresses: 
# Think of the VNet as a building (10.0.0.0/16) 
# and Subnets as rooms within that building.
VNET_PREFIX="10.0.0.0/16"
FRONT_PREFIX="10.0.1.0/24"
BACK_PREFIX="10.0.2.0/24"

# --- 2. CREATE THE INFRASTRUCTURE ---

echo "Creating the Resource Group..."
az group create --name $RG_NAME --location $LOCATION

echo "Building the Virtual Network and the Web Subnet..."
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --address-prefix $VNET_PREFIX \
  --subnet-name $FRONTEND_SUBNET \
  --subnet-prefix $FRONT_PREFIX

  echo "Creating the Private Database Subnet..."
az network vnet subnet create \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name $BACKEND_SUBNET \
  --address-prefixes $BACK_PREFIX

  echo "Creating the Security Group for the Database..."
az network nsg create \
  --resource-group $RG_NAME \
  --name "DatabaseNSG"

# Now we tell the Bouncer: "Don't let ANYONE from the internet in!"
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name "DatabaseNSG" \
  --name "DenyInternetInbound" \
  --priority 1000 \
  --access Deny \
  --source-address-prefixes "Internet" \
  --destination-port-ranges "*" \
  --direction Inbound
echo "Attaching the Bouncer to the Database Subnet..."
az network vnet subnet update \
  --resource-group $RG_NAME \
  --vnet-name $VNET_NAME \
  --name $BACKEND_SUBNET \
  --network-security-group "DatabaseNSG"

  echo "Creating the 'Internal Door' rule..."
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name "DatabaseNSG" \
  --name "AllowWebToDB" \
  --priority 100 \
  --access Allow \
  --direction Inbound \
  --source-address-prefixes $FRONT_PREFIX \
  --source-port-ranges "*" \
  --destination-address-prefixes $BACK_PREFIX \
  --destination-port-ranges 3306 \
  --protocol Tcp

echo "Creating a Public IP for the Web Server..."
az network public-ip create \
  --resource-group $RG_NAME \
  --name "WebPublicIP" \
  --sku Standard

echo "Deploying the Web Server into the WebSubnet..."
az vm create \
  --resource-group $RG_NAME \
  --name "WebServer" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name $VNET_NAME \
  --subnet $FRONTEND_SUBNET \
  --public-ip-address "WebPublicIP" \
  --admin-username "azureuser" \
  --generate-ssh-keys

echo "Opening Port 80 on the Web Server..."
az vm open-port \
  --resource-group $RG_NAME \
  --name "WebServer" \
  --port 80
echo "Deploying the Private Database Server..."
az vm create \
  --resource-group $RG_NAME \
  --name "DBServer" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name $VNET_NAME \
  --subnet $BACKEND_SUBNET \
  --public-ip-address "" \
  --admin-username "azureuser" \
  --generate-ssh-keys
