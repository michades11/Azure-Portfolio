#!/bin/bash
# ==============================================================================
# LAB 07: AUTOMATED LAYER 7 APPLICATION GATEWAY DEPLOYMENT (FIXED)
# ==============================================================================

echo "🚀 Initializing environment variables..."
export SUB_ID="959c8133-3755-4246-8b5a-23aa88e14c4d"
export RG_NAME="Lab07-Scripted-RG"       
export LOCATION="denmarkeast"             
export VNET_NAME="Lab07-Scripted-VNet"
export APPGW_NAME="Seyi-Scripted-Gateway"

# Explicitly bind to your subscription context
az account set --subscription "$SUB_ID"

echo "🏗️ Creating Resource Group: $RG_NAME..."
az group create --name "$RG_NAME" --location "$LOCATION" -o table

# 1. NETWORKING INFRASTRUCTURE
echo "🌐 Spreading VNet and subnets cleanly..."
az network vnet create \
  --name "$VNET_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name "DefaultSubnet" \
  --subnet-prefixes 10.0.0.0/24 -o table

# Creating the isolated gateway subnet
az network vnet subnet create \
  --vnet-name "$VNET_NAME" \
  --resource-group "$RG_NAME" \
  --name "AppGatewaySubnet" \
  --address-prefixes 10.0.1.0/24 -o table

# 2. PUBLIC IP FOR THE GATEWAY FRONT DOOR
echo "🎯 Allocating Static Public IP..."
az network public-ip create \
  --name "AppGatewayPublicIP" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --allocation-method Static \
  --sku Standard -o table

# 3. BACKEND COMPUTE POOLS (Placed strictly inside DefaultSubnet)
echo "🖥️ Provisioning backend virtual servers..."
az vm create \
  --resource-group "$RG_NAME" \
  --name "VM-Default-Web" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name "$VNET_NAME" \
  --subnet "DefaultSubnet" \
  --public-ip-address "" \
  --admin-username "azureuser" \
  --generate-ssh-keys -o table

az vm create \
  --resource-group "$RG_NAME" \
  --name "VM-Images-Web" \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --vnet-name "$VNET_NAME" \
  --subnet "DefaultSubnet" \
  --public-ip-address "" \
  --admin-username "azureuser" \
  --generate-ssh-keys -o table

# 4. DEPLOY THE MANAGED APPLICATION GATEWAY & RULES (WITH PRIORITY FIX)
echo "🛎️ Deploying Application Gateway Proxy (This takes 5-7 minutes)..."
az network application-gateway create \
  --name "$APPGW_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --vnet-name "$VNET_NAME" \
  --subnet "AppGatewaySubnet" \
  --capacity 2 \
  --sku Standard_v2 \
  --public-ip-address "AppGatewayPublicIP" \
  --frontend-port 80 \
  --http-settings-port 80 \
  --http-settings-protocol Http \
  --routing-rule-type Basic \
  --priority 100 -o table

echo "====================================================="
echo "💥 AUTOMATED BASE INFRASTRUCTURE DEPLOYED SUCCESSFULLY!"
echo "====================================================="