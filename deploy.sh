#!/bin/bash

# ============================================================================
# SRE Agent Hackathon - Complete Deployment Script
# ============================================================================
# This script performs a complete deployment:
# 1. Deploys infrastructure including ACR
# 2. Builds and pushes the workshop API container image
# 3. Updates the Container App with the new image
# ============================================================================

set -e  # Exit on any error

# Configuration
RESOURCE_GROUP_NAME="sre-modular-complete"
LOCATION="swedencentral"
BASE_NAME="sremodular"
POSTGRES_PASSWORD="SecurePassword123!"
CONTAINER_IMAGE_NAME="workshop-api"
CONTAINER_IMAGE_TAG="latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting SRE Agent Hackathon Complete Deployment${NC}"

# Step 1: Create Resource Group
echo -e "${YELLOW}📦 Creating resource group: $RESOURCE_GROUP_NAME${NC}"
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION

# Step 2: Deploy Infrastructure (including ACR)
echo -e "${YELLOW}🏗️  Deploying infrastructure with ACR...${NC}"
DEPLOYMENT_NAME="infrastructure-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
  --name $DEPLOYMENT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file infra/main.bicep \
  --parameters baseName=$BASE_NAME \
  --parameters postgresAdminPassword="$POSTGRES_PASSWORD" \
  --parameters containerImage="$CONTAINER_IMAGE_NAME:$CONTAINER_IMAGE_TAG"

# Step 3: Get ACR details
echo -e "${YELLOW}🔍 Getting ACR details...${NC}"
ACR_NAME=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.acrName.value" \
  --output tsv)

ACR_LOGIN_SERVER=$(az deployment group show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $DEPLOYMENT_NAME \
  --query "properties.outputs.acrLoginServer.value" \
  --output tsv)

echo -e "${GREEN}✅ ACR Name: $ACR_NAME${NC}"
echo -e "${GREEN}✅ ACR Login Server: $ACR_LOGIN_SERVER${NC}"

# Step 4: Login to ACR
echo -e "${YELLOW}🔑 Logging in to ACR...${NC}"
az acr login --name $ACR_NAME

# Step 5: Build and push container image
echo -e "${YELLOW}🐳 Building and pushing container image...${NC}"
FULL_IMAGE_NAME="$ACR_LOGIN_SERVER/$CONTAINER_IMAGE_NAME:$CONTAINER_IMAGE_TAG"

# Build the image from the API source directory
az acr build \
  --registry $ACR_NAME \
  --image "$CONTAINER_IMAGE_NAME:$CONTAINER_IMAGE_TAG" \
  --file src/api/Dockerfile \
  src/api/

echo -e "${GREEN}✅ Container image built and pushed: $FULL_IMAGE_NAME${NC}"

# Step 6: Get Container App details for verification
echo -e "${YELLOW}🔍 Getting Container App details...${NC}"
CONTAINER_APP_NAME=$(az containerapp list \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "[0].name" \
  --output tsv)

CONTAINER_APP_URL=$(az containerapp show \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv)

# Step 7: Wait for deployment to complete and test
echo -e "${YELLOW}⏳ Waiting for Container App to update...${NC}"
sleep 60

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📊 Resource Summary:${NC}"
echo -e "  Resource Group: $RESOURCE_GROUP_NAME"
echo -e "  ACR Name: $ACR_NAME"
echo -e "  Container Image: $FULL_IMAGE_NAME"
echo -e "  Container App: $CONTAINER_APP_NAME"
echo -e "  Container App URL: https://$CONTAINER_APP_URL"

echo -e "${BLUE}🧪 Testing API endpoint:${NC}"
curl -s "https://$CONTAINER_APP_URL/health" && echo -e "${GREEN}✅ API is responding${NC}" || echo -e "${RED}❌ API not responding yet${NC}"

echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "  1. Test the API: curl https://$CONTAINER_APP_URL/"
echo -e "  2. View logs: az containerapp logs show --name $CONTAINER_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
echo -e "  3. Monitor in Azure Portal"