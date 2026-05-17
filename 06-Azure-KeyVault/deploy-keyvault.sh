#!/bin/bash
# ==============================================================================
# LAB 06: AUTOMATED SECURE SECRETS MANAGEMENT 
# PURPOSE: Deploy an isolated Key Vault, map RBAC identities, and secure secrets.
# ==============================================================================

# 1. INITIALIZE GLOBAL CONFIGURATION
echo "🚀 Initializing environment variables..."
export SUB_ID="959c8133-3755-4246-8b5a-23aa88e14c4d"
export RG_NAME="Lab06-KeyVault-RG"
export LOCATION="eastus"
export VAULT_NAME="seyi-safe-$RANDOM" # $RANDOM ensures global uniqueness

# Force the CLI to focus on your specific active billing subscription
az account set --subscription "$SUB_ID"

# 2. CREATE THE RESOURCE RESOURCE GROUP
echo "🏗️ Creating resource group: $RG_NAME..."
az group create --name "$RG_NAME" --location "$LOCATION" -o table

# 3. DEPLOY KEY VAULT WITH ENTERPRISE RBAC ENABLED
echo "🛡️ Deploying Key Vault: $VAULT_NAME..."
az keyvault create \
  --name "$VAULT_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --enable-rbac-authorization true \
  -o table

# 4. RESOLVE IDENTITY & ASSIGN DATA-PLANE PERMISSIONS
echo "🔑 Resolving active user identity..."
MY_ID=$(az ad signed-in-user show --query id -o tsv)

echo "🎖️ Assigning 'Key Vault Secrets Officer' role..."
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee "$MY_ID" \
  --scope "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME/providers/Microsoft.KeyVault/vaults/$VAULT_NAME" \
  -o table

# 5. PROPAGATION DELAY (Bypasses the security race condition)
echo "⏳ Waiting 45 seconds for Azure RBAC permissions to propagate globally..."
sleep 45

# 6. INJECT SENSITIVE DATA (The Secret)
echo "📥 Injecting production database credential into the vault..."
az keyvault secret set \
  --vault-name "$VAULT_NAME" \
  --name "AppDatabasePassword" \
  --value "SecureSeyi2026!" \
  -o table

# 7. VERIFY COMPLIANCE & RETRIEVAL
echo "📤 Simulating application startup: Fetching secret from data plane..."
FETCHED_PASS=$(az keyvault secret show \
  --name "AppDatabasePassword" \
  --vault-name "$VAULT_NAME" \
  --query "value" \
  -o tsv)

echo "====================================================="
echo "💥 SUCCESS! Application retrieved secret: $FETCHED_PASS"
echo "====================================================="