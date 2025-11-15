#!/bin/bash
set -e

# ============================================================================
# Phase 2: Applications Deployment Script
# ============================================================================
# This script deploys Container Apps with actual built images
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

# Check if deployment info exists
if [[ ! -f "deployment-info.json" ]]; then
    echo "Error: deployment-info.json not found. Please run Phase 1 first."
    exit 1
fi

# Load deployment info from Phase 1
RESOURCE_GROUP_NAME=$(jq -r '.resourceGroupName' deployment-info.json)
LOCATION=$(jq -r '.location' deployment-info.json)
ENVIRONMENT=$(jq -r '.environmentName' deployment-info.json)
BASE_NAME=$(jq -r '.baseName' deployment-info.json)
ACR_NAME=$(jq -r '.acrName' deployment-info.json)
ACR_LOGIN_SERVER=$(jq -r '.acrLoginServer' deployment-info.json)

# Configuration
CONTAINER_IMAGE_NAME="workshop-api:v1.0.0"

echo "🚀 Starting Phase 2: Applications Deployment"
echo "============================================="
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "ACR: $ACR_NAME"
echo "Container Image: $CONTAINER_IMAGE_NAME"
echo

# Prompt for PostgreSQL password (same as Phase 1)
echo "Enter PostgreSQL administrator password (same as Phase 1):"
read -s POSTGRES_PASSWORD

# Check if the container image exists
echo "🔍 Checking if container image exists..."
if ! az acr repository show --name "$ACR_NAME" --image "$CONTAINER_IMAGE_NAME" &> /dev/null; then
    echo "❌ Container image '$CONTAINER_IMAGE_NAME' not found in ACR '$ACR_NAME'"
    echo
    echo "Please build and push your image first:"
    echo "  cd ../src/api"
    echo "  az acr build --registry $ACR_NAME --image $CONTAINER_IMAGE_NAME ."
    echo
    echo "Or if you have a Dockerfile in a different location:"
    echo "  az acr build --registry $ACR_NAME --image $CONTAINER_IMAGE_NAME --file path/to/Dockerfile ."
    exit 1
fi

echo "✅ Container image found in ACR"
echo

echo "🏗️  Deploying applications and API Management..."

# Deploy applications
az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "apps.bicep" \
    --parameters \
        location="$LOCATION" \
        environmentName="$ENVIRONMENT" \
        baseName="$BASE_NAME" \
        containerImageRegistry="$ACR_LOGIN_SERVER" \
        containerImageName="$CONTAINER_IMAGE_NAME" \
        postgresAdminPassword="$POSTGRES_PASSWORD" \
    --output table

# Get deployment outputs
echo
echo "📋 Retrieving application information..."
APP_DEPLOYMENT_OUTPUT=$(az deployment group show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "apps" \
    --query "properties.outputs" \
    --output json)

API_URL=$(echo "$APP_DEPLOYMENT_OUTPUT" | jq -r '.apiContainerAppUrl.value')
APIM_GATEWAY_URL=$(echo "$APP_DEPLOYMENT_OUTPUT" | jq -r '.apimGatewayUrl.value')
APIM_API_URL=$(echo "$APP_DEPLOYMENT_OUTPUT" | jq -r '.apimApiUrl.value')

echo
echo "✅ Phase 2 Complete!"
echo "===================="
echo "API URL (direct): $API_URL"
echo "APIM Gateway URL: $APIM_GATEWAY_URL"
echo "APIM API URL: $APIM_API_URL"
echo
echo "🧪 Testing your API:"
echo "Direct: curl $API_URL/health"
echo "Via APIM: curl -H \"Ocp-Apim-Subscription-Key: <KEY>\" $APIM_API_URL/health"
echo
echo "� To get APIM subscription key:"
echo "az rest --method post --url \"\$(az apim show --name <APIM_NAME> --query id -o tsv)/subscriptions/master/listSecrets?api-version=2023-05-01-preview\" --query primaryKey -o tsv"
echo
echo "🔧 Next Steps:"
echo "1. Test your API endpoints"
echo "2. Set up monitoring and alerts"
echo "3. Configure additional APIM policies if needed"
echo

# Update deployment info
jq --arg api_url "$API_URL" '. + {apiUrl: $api_url}' deployment-info.json > deployment-info-updated.json
mv deployment-info-updated.json deployment-info.json

echo "💾 Deployment information updated in deployment-info.json"