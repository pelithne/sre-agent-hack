// ============================================================================
// Azure SRE Agent Hackathon - Infrastructure-Only Template (Phase 1)
// ============================================================================
// This template deploys core infrastructure without Container Apps:
// - Networking: VNet, subnets, private DNS zones
// - Monitoring: Log Analytics, Application Insights
// - Identity: Managed identity with ACR integration
// - ACR: Azure Container Registry for building images
// - Database: PostgreSQL Flexible Server with private networking
// ============================================================================

targetScope = 'resourceGroup'

import { ResourceTags } from './modules/types.bicep'

// ============================================================================
// Parameters
// ============================================================================

@description('The primary location for all resources')
param location string = resourceGroup().location

@description('Environment name (e.g., dev, staging, prod)')
@minLength(2)
@maxLength(10)
param environmentName string = 'dev'

@description('Base name for resources (used to generate unique resource names)')
@minLength(3)
@maxLength(15)
param baseName string = 'sreagent'

@description('Administrator username for PostgreSQL')
@minLength(1)
param postgresAdminUsername string = 'sqladmin'

@description('Administrator password for PostgreSQL')
@secure()
@minLength(12)
param postgresAdminPassword string

@description('Tags to apply to all resources')
param tags ResourceTags = {
  Environment: environmentName
  ManagedBy: 'Bicep'
  Project: 'SRE-Agent-Hackathon'
}

// ============================================================================
// Variables
// ============================================================================

var uniqueSuffix = uniqueString(resourceGroup().id)
var namingPrefix = '${baseName}-${environmentName}'

// Configuration objects for modules
var namingConfig = {
  baseName: baseName
  environmentName: environmentName
  uniqueSuffix: uniqueSuffix
  namingPrefix: namingPrefix
}

var networkConfig = {
  vnetAddressPrefix: '10.0.0.0/16'
  containerAppsSubnetPrefix: '10.0.0.0/23'
  postgresSubnetPrefix: '10.0.2.0/24'
  apimSubnetPrefix: '10.0.3.0/24'
}

var databaseConfig = {
  adminUsername: postgresAdminUsername
  adminPassword: postgresAdminPassword
  databaseName: 'workshopdb'
  sku: 'Standard_B1ms'
  storageSizeGB: 32
  backupRetentionDays: 7
  highAvailability: 'Disabled'
}

var monitoringConfig = {
  logRetentionDays: 30
  applicationType: 'web'
  requestSource: 'rest'
  flowType: 'Bluefield'
  samplingPercentage: 100
}

var apiManagementConfig = {
  skuName: 'Consumption'
  skuCapacity: 0
  publisherEmail: 'admin@workshop.local'
  publisherName: 'Workshop Admin'
}

// ============================================================================
// Module Deployments
// ============================================================================

// Deploy networking infrastructure
module networking './modules/networking.bicep' = {
  name: 'networking-deployment'
  params: {
    location: location
    networkConfig: networkConfig
    namingConfig: namingConfig
    tags: tags
  }
}

// Deploy monitoring infrastructure
module monitoring './modules/monitoring.bicep' = {
  name: 'monitoring-deployment'
  params: {
    location: location
    monitoringConfig: monitoringConfig
    namingConfig: namingConfig
    tags: tags
  }
}

// Deploy Azure Container Registry
module acr './modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    location: location
    namingConfig: namingConfig
    tags: tags
  }
}

// Deploy identity infrastructure (depends on ACR)
module identity './modules/identity.bicep' = {
  name: 'identity-deployment'
  params: {
    location: location
    namingConfig: namingConfig
    tags: tags
    acrName: acr.outputs.acrName
  }
}

// Deploy database infrastructure
module database './modules/database.bicep' = {
  name: 'database-deployment'
  params: {
    location: location
    databaseConfig: databaseConfig
    namingConfig: namingConfig
    tags: tags
    postgresSubnetId: networking.outputs.postgresSubnetId
    postgresDnsZoneId: networking.outputs.postgresDnsZoneId
  }
}

// Deploy API Management infrastructure (without APIs - those come in Phase 2)
module apiManagement './modules/apim-infrastructure.bicep' = {
  name: 'apim-deployment'
  params: {
    location: location
    apiManagementConfig: apiManagementConfig
    namingConfig: namingConfig
    tags: tags
    apimSubnetId: networking.outputs.apimSubnetId
    appInsightsId: monitoring.outputs.appInsightsId
    appInsightsName: monitoring.outputs.appInsightsName
    appInsightsInstrumentationKey: monitoring.outputs.appInsightsInstrumentationKey
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('ACR Name')
output acrName string = acr.outputs.acrName

@description('ACR Login Server')
output acrLoginServer string = acr.outputs.acrLoginServer

@description('Virtual Network ID')
output vnetId string = networking.outputs.vnetId

@description('Container Apps Subnet ID (for Phase 2)')
output containerAppsSubnetId string = networking.outputs.containerAppsSubnetId

@description('Managed Identity ID (for Phase 2)')
output managedIdentityId string = identity.outputs.managedIdentityId

@description('PostgreSQL Server FQDN')
output postgresServerFqdn string = database.outputs.postgresServerFqdn

@description('PostgreSQL Database Name')
output postgresDatabaseName string = database.outputs.postgresDatabaseName

@description('PostgreSQL Admin Username')
output postgresAdminUsername string = database.outputs.postgresAdminUsername

@description('Log Analytics Customer ID (for Phase 2)')
output logAnalyticsCustomerId string = monitoring.outputs.logAnalyticsCustomerId

@description('Log Analytics Shared Key (for Phase 2)')
output logAnalyticsSharedKey string = monitoring.outputs.logAnalyticsSharedKey

@description('Application Insights Connection String (for Phase 2)')
output appInsightsConnectionString string = monitoring.outputs.appInsightsConnectionString

@description('Application Insights ID (for Phase 2)')
output appInsightsId string = monitoring.outputs.appInsightsId

@description('Application Insights Name (for Phase 2)')
output appInsightsName string = monitoring.outputs.appInsightsName

@description('Application Insights Instrumentation Key (for Phase 2)')
output appInsightsInstrumentationKey string = monitoring.outputs.appInsightsInstrumentationKey

@description('APIM Service ID (for Phase 2)')
output apimId string = apiManagement.outputs.apimId

@description('APIM Service Name (for Phase 2)')
output apimName string = apiManagement.outputs.apimName

@description('APIM Gateway URL')
output apimGatewayUrl string = apiManagement.outputs.apimGatewayUrl

@description('Infrastructure deployment summary')
output deploymentInfo object = {
  environment: environmentName
  baseName: baseName
  location: location
  phase: 'infrastructure'
  acr: {
    name: acr.outputs.acrName
    loginServer: acr.outputs.acrLoginServer
  }
  readyForPhase2: true
  nextSteps: [
    '1. Build container image: az acr build --registry ${acr.outputs.acrName} --image workshop-api:v1.0.0 --file src/api/Dockerfile src/api'
    '2. Deploy Container Apps using infra/apps.bicep'
    '3. Deploy API Management using infra/apim.bicep'
  ]
}
