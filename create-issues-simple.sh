#!/bin/bash
set -e

REPO="pelithne/sre-agent-hack"
TOKEN="$GITHUB_TOKEN"

create_issue() {
  local title="$1"
  local body="$2"
  local labels="$3"
  
  curl -s -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/issues" \
    -d @- << EOF | jq -r '"\(.number) - \(.title)"'
{
  "title": "$title",
  "body": "$body",
  "labels": $labels
}
EOF
  sleep 1
}

echo "Creating GitHub issues..."

create_issue \
  "Create Bicep infrastructure templates" \
  "Develop comprehensive Bicep templates for the workshop infrastructure:\n- Azure API Management (Developer tier)\n- Azure Container Apps Environment and Container App\n- Azure Database for PostgreSQL Flexible Server\n- Virtual Network and subnets\n- Managed Identity and RBAC assignments\n- Application Insights for monitoring\n- Log Analytics Workspace\n\nTemplates should be modular and include parameters for easy customization." \
  '["infrastructure", "bicep"]'

create_issue \
  "Create sample API application" \
  "Build a simple REST API application that:\n- Connects to PostgreSQL database\n- Exposes CRUD endpoints for a sample entity (e.g., products, tasks)\n- Includes health check endpoints\n- Has proper logging and error handling\n- Can be containerized and deployed to Azure Container Apps\n- Works with API Management\n\nLanguage: Python (Flask/FastAPI) or Node.js (Express)" \
  '["application", "api"]'

create_issue \
  "Create workshop exercises - Part 1: Setup and Deployment" \
  "Write detailed step-by-step instructions for:\n- Setting up the development environment\n- Deploying the Bicep templates\n- Building and deploying the container app\n- Configuring API Management\n- Testing the deployed application\n- Verifying all services are running correctly\n\nInclude troubleshooting tips and expected outputs." \
  '["documentation", "workshop", "setup"]'

create_issue \
  "Create workshop exercises - Part 2: SRE Agent Troubleshooting" \
  "Design exercises that teach participants how to use Azure SRE Agent:\n- Exercise 2.1: Database connection issues (wrong connection string)\n- Exercise 2.2: Performance degradation (slow queries, resource constraints)\n- Exercise 2.3: Configuration errors (missing environment variables)\n- Exercise 2.4: API Management policy issues\n- Exercise 2.5: Container app deployment failures\n\nEach exercise should include:\n- How to introduce the error\n- Symptoms to observe\n- How to engage SRE Agent\n- Expected diagnosis and resolution steps" \
  '["documentation", "workshop", "sre-agent"]'

create_issue \
  "Create workshop exercises - Part 3: Monitoring and Incident Management" \
  "Create comprehensive instructions for:\n- Setting up Azure Monitor alerts (availability, performance, errors)\n- Configuring action groups\n- Connecting SRE Agent to alert notifications\n- Performing incident investigations with SRE Agent\n- Creating Root Cause Analysis (RCA) reports\n- Post-incident review process\n\nInclude sample alert rules and KQL queries." \
  '["documentation", "workshop", "monitoring", "sre-agent"]'

create_issue \
  "Create advanced and bonus exercises" \
  "Design additional challenging exercises:\n- Auto-remediation scenarios with SRE Agent\n- Multi-service debugging (API → Container App → Database)\n- Performance optimization using SRE Agent insights\n- Security incident investigation\n- Chaos engineering experiments\n- Cost optimization recommendations\n- Implementing SRE best practices\n\nThese exercises should demonstrate advanced SRE Agent capabilities." \
  '["documentation", "workshop", "advanced", "sre-agent"]'

create_issue \
  "Create supporting scripts and documentation" \
  "Develop helper resources:\n- Deployment automation scripts (bash/PowerShell)\n- Error injection scripts for exercises\n- Environment setup validation script\n- Cleanup script to remove all resources\n- Troubleshooting guide\n- FAQ section\n- Additional resources and links\n\nEnsure all scripts are well-documented and idempotent." \
  '["documentation", "scripts", "tooling"]'

echo -e "\n✓ All issues created successfully!"
