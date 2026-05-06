#!/bin/bash
# Stop the script if any command fails
set -e
# Print commands to screen so you can watch the progress
set -x

# 1. THE BLUEPRINT (Variables)
RG_NAME="Lab03-HighAvailability-RG"
LOCATION="westus2"
VNET_NAME="Lab03-VNet"
SUBNET_NAME="Web-Subnet"
LB_NAME="MyLoadBalancer"

# 2. THE FOUNDATION
echo "Step 1: Creating the Resource Group..."
az group create --name $RG_NAME --location $LOCATION

echo "Step 2: Creating the Network Foundation..."
az network vnet create \
  --resource-group $RG_NAME \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.0.1.0/24

# 3. SECURITY (Building the Guard before the Workers)
echo "Step 3: Creating the Security Group and Rules..."
az network nsg create --resource-group $RG_NAME --name "Web-VM-NSG"

az network nsg rule create \
  --resource-group $RG_NAME \
  --nsg-name "Web-VM-NSG" \
  --name AllowHTTP \
  --priority 100 \
  --destination-port-ranges 80 \
  --access Allow \
  --protocol Tcp

# 4. THE GATE (Load Balancer)
echo "Step 4: Creating Public IP..."
az network public-ip create --resource-group $RG_NAME --name LBPublicIP --sku Standard

echo "Step 5: Building Load Balancer Shell..."
az network lb create \
  --resource-group $RG_NAME \
  --name $LB_NAME \
  --sku Standard \
  --public-ip-address LBPublicIP \
  --frontend-ip-name MyFrontend \
  --backend-pool-name MyBackendPool

echo "Step 6: Configuring the Health Probe..."
# Note: '//' fix for Git Bash pathing issues
az network lb probe create \
  --resource-group $RG_NAME \
  --lb-name $LB_NAME \
  --name MyHealthProbe \
  --protocol http \
  --port 80 \
  --path //

echo "Step 7: Creating the Balancing Rule..."
az network lb rule create \
  --resource-group $RG_NAME \
  --lb-name $LB_NAME \
  --name MyHTTPRule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name MyFrontend \
  --backend-pool-name MyBackendPool \
  --probe-name MyHealthProbe

# 5. THE WORKERS (Iterative Creation)
echo "Step 8: Creating NICs and VMs..."
for i in 1 2
do
   echo "Creating NIC for Web-VM-$i..."
   az network nic create \
     --resource-group $RG_NAME \
     --name "Web-VM-$i-NIC" \
     --vnet-name $VNET_NAME \
     --subnet $SUBNET_NAME \
     --lb-name $LB_NAME \
     --lb-address-pools MyBackendPool \
     --network-security-group "Web-VM-NSG"

   echo "Launching Web-VM-$i..."
   az vm create \
     --resource-group $RG_NAME \
     --name "Web-VM-$i" \
     --nics "Web-VM-$i-NIC" \
     --image Ubuntu2204 \
     --size Standard_D2s_v3 \
     --admin-username seyiadmin \
     --admin-password "$VM_PASSWORD" \
     --custom-data cloud-init.txt \
     --data-disk-sizes-gb 10
done

echo "---------------------------------------------------------------"
echo "DEPLOYMENT COMPLETE!"
echo "PUBLIC IP: $(az network public-ip show --resource-group $RG_NAME --name LBPublicIP --query ipAddress -o tsv)"
echo "---------------------------------------------------------------"