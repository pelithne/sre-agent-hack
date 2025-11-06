#!/bin/bash

# Script to create GitHub issues for the SRE Agent Hackathon workshop
# Usage: ./create-github-issues.sh
# Requires: GITHUB_TOKEN environment variable to be set

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable is not set"
    echo "Please set it with: export GITHUB_TOKEN='your_token_here'"
    exit 1
fi

REPO_OWNER="pelithne"
REPO_NAME="sre-agent-hack"

echo "Creating GitHub issues for repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Issue 1: Main README
echo "Creating issue: Create main workshop README..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create main workshop README and documentation structure",
    "body": "Create the foundational README.md file that includes:\n- Workshop overview and objectives\n- Prerequisites (Azure subscription, tools, SRE Agent setup)\n- Architecture diagram description\n- Learning objectives focused on Azure SRE Agent capabilities\n- Navigation to different workshop sections\n\nThis will serve as the entry point for all workshop participants.",
    "labels": ["documentation", "workshop"]
  }'

echo -e "\n✓ Issue 1 created\n"

# Issue 2: Bicep templates
echo "Creating issue: Create Bicep infrastructure templates..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create Bicep infrastructure templates",
    "body": "Develop comprehensive Bicep templates for the workshop infrastructure:\n- Azure API Management (Developer tier)\n- Azure Container Apps Environment and Container App\n- Azure Database for PostgreSQL Flexible Server\n- Virtual Network and subnets\n- Managed Identity and RBAC assignments\n- Application Insights for monitoring\n- Log Analytics Workspace\n\nTemplates should be modular and include parameters for easy customization.",
    "labels": ["infrastructure", "bicep"]
  }'

echo -e "\n✓ Issue 2 created\n"

# Issue 3: Sample API
echo "Creating issue: Create sample API application..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create sample API application",
    "body": "Build a simple REST API application that:\n- Connects to PostgreSQL database\n- Exposes CRUD endpoints for a sample entity (e.g., products, tasks)\n- Includes health check endpoints\n- Has proper logging and error handling\n- Can be containerized and deployed to Azure Container Apps\n- Works with API Management\n\nLanguage: Python (Flask/FastAPI) or Node.js (Express)",
    "labels": ["application", "api"]
  }'

echo -e "\n✓ Issue 3 created\n"

# Issue 4: Workshop Part 1
echo "Creating issue: Workshop exercises Part 1..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create workshop exercises - Part 1: Setup and Deployment",
    "body": "Write detailed step-by-step instructions for:\n- Setting up the development environment\n- Deploying the Bicep templates\n- Building and deploying the container app\n- Configuring API Management\n- Testing the deployed application\n- Verifying all services are running correctly\n\nInclude troubleshooting tips and expected outputs.",
    "labels": ["documentation", "workshop", "setup"]
  }'

echo -e "\n✓ Issue 4 created\n"

# Issue 5: Workshop Part 2
echo "Creating issue: Workshop exercises Part 2..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create workshop exercises - Part 2: SRE Agent Troubleshooting",
    "body": "Design exercises that teach participants how to use Azure SRE Agent:\n- Exercise 2.1: Database connection issues (wrong connection string)\n- Exercise 2.2: Performance degradation (slow queries, resource constraints)\n- Exercise 2.3: Configuration errors (missing environment variables)\n- Exercise 2.4: API Management policy issues\n- Exercise 2.5: Container app deployment failures\n\nEach exercise should include:\n- How to introduce the error\n- Symptoms to observe\n- How to engage SRE Agent\n- Expected diagnosis and resolution steps",
    "labels": ["documentation", "workshop", "sre-agent"]
  }'

echo -e "\n✓ Issue 5 created\n"

# Issue 6: Workshop Part 3
echo "Creating issue: Workshop exercises Part 3..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create workshop exercises - Part 3: Monitoring and Incident Management",
    "body": "Create comprehensive instructions for:\n- Setting up Azure Monitor alerts (availability, performance, errors)\n- Configuring action groups\n- Connecting SRE Agent to alert notifications\n- Performing incident investigations with SRE Agent\n- Creating Root Cause Analysis (RCA) reports\n- Post-incident review process\n\nInclude sample alert rules and KQL queries.",
    "labels": ["documentation", "workshop", "monitoring", "sre-agent"]
  }'

echo -e "\n✓ Issue 6 created\n"

# Issue 7: Advanced exercises
echo "Creating issue: Advanced exercises..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create advanced and bonus exercises",
    "body": "Design additional challenging exercises:\n- Auto-remediation scenarios with SRE Agent\n- Multi-service debugging (API → Container App → Database)\n- Performance optimization using SRE Agent insights\n- Security incident investigation\n- Chaos engineering experiments\n- Cost optimization recommendations\n- Implementing SRE best practices\n\nThese exercises should demonstrate advanced SRE Agent capabilities.",
    "labels": ["documentation", "workshop", "advanced", "sre-agent"]
  }'

echo -e "\n✓ Issue 7 created\n"

# Issue 8: Supporting scripts
echo "Creating issue: Supporting scripts and documentation..."
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues" \
  -d '{
    "title": "Create supporting scripts and documentation",
    "body": "Develop helper resources:\n- Deployment automation scripts (bash/PowerShell)\n- Error injection scripts for exercises\n- Environment setup validation script\n- Cleanup script to remove all resources\n- Troubleshooting guide\n- FAQ section\n- Additional resources and links\n\nEnsure all scripts are well-documented and idempotent.",
    "labels": ["documentation", "scripts", "tooling"]
  }'

echo -e "\n✓ Issue 8 created\n"

echo "All GitHub issues have been created successfully!"
