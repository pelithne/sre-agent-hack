#!/bin/bash
set -e

# ============================================================================
# Build Script Example for SRE Agent Hackathon
# ============================================================================
# This script shows how to build a container image for the workshop
# Customize this script based on your actual application structure
# ============================================================================

# Check if deployment info exists
if [[ ! -f "./infra/deployment-info.json" ]]; then
    echo "Error: deployment-info.json not found. Please run Phase 1 first."
    echo "Run: cd infra && ./deploy-phase1.sh"
    exit 1
fi

# Load ACR name from deployment info
ACR_NAME=$(jq -r '.acrName' ./infra/deployment-info.json)

if [[ "$ACR_NAME" == "null" || -z "$ACR_NAME" ]]; then
    echo "Error: Could not find ACR name in deployment-info.json"
    exit 1
fi

echo "🔨 Building container image for SRE Workshop"
echo "============================================"
echo "ACR: $ACR_NAME"
echo

# Configuration
IMAGE_NAME="workshop-api"
IMAGE_TAG="v1.0.0"
DOCKERFILE_PATH="./src/api/Dockerfile"
BUILD_CONTEXT="./src/api"

# Check if source directory exists
if [[ ! -d "$BUILD_CONTEXT" ]]; then
    echo "❌ Source directory '$BUILD_CONTEXT' not found."
    echo
    echo "Please create your application structure:"
    echo "  src/api/          - Your application code"
    echo "  src/api/Dockerfile - Container build instructions"
    echo
    echo "Or modify this script to point to your actual application directory."
    exit 1
fi

# Check if Dockerfile exists
if [[ ! -f "$DOCKERFILE_PATH" ]]; then
    echo "❌ Dockerfile not found at '$DOCKERFILE_PATH'"
    echo
    echo "Please create a Dockerfile in your application directory."
    echo "Example Dockerfile for a Node.js app:"
    echo
    cat << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
EOF
    echo
    exit 1
fi

echo "🔍 Found application files:"
echo "  Dockerfile: $DOCKERFILE_PATH"
echo "  Build context: $BUILD_CONTEXT"
echo

echo "🏗️  Building and pushing container image..."
echo "Image: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
echo

# Build and push the image
az acr build \
    --registry "$ACR_NAME" \
    --image "$IMAGE_NAME:$IMAGE_TAG" \
    --file "$DOCKERFILE_PATH" \
    "$BUILD_CONTEXT"

if [[ $? -eq 0 ]]; then
    echo
    echo "✅ Container image built successfully!"
    echo "Image: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
    echo
    echo "🚀 Ready for Phase 2 deployment:"
    echo "cd infra && ./deploy-phase2.sh"
else
    echo
    echo "❌ Container build failed!"
    echo "Check the error messages above and fix your Dockerfile or application code."
    exit 1
fi