#!/bin/bash
set -e
set -x

# 1. SETTINGS
RG_NAME="Lab04-Scaling-RG"
LOCATION="westus2"
VMSS_NAME="Web-ScaleSet"

# 2. CREATE RESOURCE GROUP
az group create --name $RG_NAME --location $LOCATION

# 3. CREATE THE SCALE SET
# This command builds the LB, the VNet, and the VMs all at once!
az vmss create \
  --resource-group $RG_NAME \
  --name $VMSS_NAME \
  --image Ubuntu2204 \
  --vm-sku Standard_D2s_v3 \
  --instance-count 2 \
  --admin-username seyiadmin \
  --admin-password "$VM_PASSWORD" \
  --custom-data cloud-init.txt \
  --lb-sku Standard \
  --backend-pool-name MyBackendPool \
  --upgrade-policy-mode Automatic \
  --data-disk-sizes-gb 10

  # 4. OPEN THE FRONT DOOR (Port 80)
# This allows traffic to hit your Scale Set
az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name "${VMSS_NAME}NSG" \
  --name AllowHTTP \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

# 5. CREATE AUTOSCALE SETTINGS
# This defines the "Safety Rails" (Min 2 servers, Max 5 servers)
az monitor autoscale create \
  --resource-group $RG_NAME \
  --resource $VMSS_NAME \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name "AutoscalePolicy" \
  --min-count 2 \
  --max-count 5 \
  --count 2

# 6. THE "HIRE" RULE (Scale Out)
# If CPU > 75% for 5 mins, add 1 VM
az monitor autoscale rule create \
  --resource-group $RG_NAME \
  --autoscale-name "AutoscalePolicy" \
  --condition "Percentage CPU > 75 avg 5m" \
  --scale out 1

# 7. THE "FIRE" RULE (Scale In)
# If CPU < 25% for 10 mins, remove 1 VM to save money
az monitor autoscale rule create \
  --resource-group $RG_NAME \
  --autoscale-name "AutoscalePolicy" \
  --condition "Percentage CPU < 25 avg 10m" \
  --scale in 1

echo "---------------------------------------------------------------"
echo "AUTOSCALING CLUSTER DEPLOYED!"
echo "Check your Public IP in the Portal under Load Balancer settings."
echo "---------------------------------------------------------------"