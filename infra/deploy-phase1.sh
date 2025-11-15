#!/bin/bash
set -e

# ============================================================================
# Phase 1: Infrastructure Deployment Script
# ============================================================================
# This script deploys the core infrastructure without Container Apps
# ============================================================================

# Check if Azure CLI is installed and logged in
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    exit 1
fi

if ! az account show &> /dev/null; then
    echo "Error: Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Configuration
RESOURCE_GROUP_NAME="rg-sre-agent-hackathon"
LOCATION="eastus"
ENVIRONMENT="dev"
BASE_NAME="sreagent"

# Prompt for PostgreSQL password
echo "Enter PostgreSQL administrator password (min 12 characters):"
read -s POSTGRES_PASSWORD

if [[ ${#POSTGRES_PASSWORD} -lt 12 ]]; then
    echo "Error: Password must be at least 12 characters long."
    exit 1
fi

echo
echo "🚀 Starting Phase 1: Infrastructure Deployment"
echo "============================================="
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Location: $LOCATION"
echo "Environment: $ENVIRONMENT"
echo "Base Name: $BASE_NAME"
echo

# Create resource group if it doesn't exist
echo "📦 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --output table

echo
echo "🏗️  Deploying infrastructure..."

# Deploy infrastructure
az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "infrastructure.bicep" \
    --parameters \
        location="$LOCATION" \
        environmentName="$ENVIRONMENT" \
        baseName="$BASE_NAME" \
        postgresAdminPassword="$POSTGRES_PASSWORD" \
    --output table

# Get deployment outputs
echo
echo "📋 Retrieving deployment information..."
DEPLOYMENT_OUTPUT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "infrastructure" \
    --query "properties.outputs" \
    --output json)

ACR_NAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.acrName.value')
ACR_LOGIN_SERVER=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.acrLoginServer.value')

echo
echo "✅ Phase 1 Complete!"
echo "===================="
echo "ACR Name: $ACR_NAME"
echo "ACR Login Server: $ACR_LOGIN_SERVER"
echo
echo "🔧 Next Steps:"
echo "1. Build your container image:"
echo "   az acr build --registry $ACR_NAME --image workshop-api:v1.0.0 --file src/api/Dockerfile src/api"
echo
echo "2. Run Phase 2 deployment:"
echo "   ./deploy-phase2.sh"
echo

# Save deployment info for phase 2
cat > deployment-info.json << EOF
{
  "resourceGroupName": "$RESOURCE_GROUP_NAME",
  "location": "$LOCATION",
  "environmentName": "$ENVIRONMENT",
  "baseName": "$BASE_NAME",
  "acrName": "$ACR_NAME",
  "acrLoginServer": "$ACR_LOGIN_SERVER"
}
EOF

echo "💾 Deployment information saved to deployment-info.json"