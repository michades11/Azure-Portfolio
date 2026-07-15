#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Azure Monitoring Lab Deployment..."

# 1. Create Resource Group
echo "Creating Resource Group..."
az group create --name Lab09-Monitor-RG --location denmarkeast

# 2. Deploy VM (Target with Private IP only)
echo "Deploying Standard_B2s VM..."
az vm create \
  --resource-group Lab09-Monitor-RG \
  --name VM-Monitor-Target \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --location denmarkeast \
  --public-ip-address ""

# 3. Recreate Network Watcher RG & Enable Service
echo "Enabling Network Watcher..."
az group create --name NetworkWatcherRG --location denmarkeast
az network watcher configure --resource-group NetworkWatcherRG --locations denmarkeast --enabled true

# 4. Generate Unique Storage Account
RANDOM_SUFIX=$RANDOM
echo "Creating Storage Account (saforflowlogs$RANDOM_SUFIX)..."
az storage account create \
  --name saforflowlogs$RANDOM_SUFIX \
  --resource-group Lab09-Monitor-RG \
  --location denmarkeast \
  --sku Standard_LRS \
  --kind StorageV2

# 5. Extract Network IDs
echo "Retrieving Network Resource IDs..."
VNET_ID=$(az network vnet list --resource-group Lab09-Monitor-RG --query "[0].id" --output tsv)
SA_ID=$(az storage account show --resource-group Lab09-Monitor-RG --name saforflowlogs$RANDOM_SUFIX --query id --output tsv)

# 6. Enable VNet Flow Logs
echo "Enabling Modern VNet Flow Logs..."
az network watcher flow-log create \
  --location denmarkeast \
  --resource-group NetworkWatcherRG \
  --name TargetVM-FlowLogs \
  --vnet $VNET_ID \
  --storage-account $SA_ID \
  --enabled true

echo "Deployment complete! Run 'az network watcher test-ip-flow' to run diagnostic tests."