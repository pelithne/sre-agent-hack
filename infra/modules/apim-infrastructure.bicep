// ============================================================================
// API Management Infrastructure Module (Phase 1)
// ============================================================================
// This module creates only the API Management service infrastructure.
// APIs and backends are configured separately in Phase 2.
// ============================================================================

targetScope = 'resourceGroup'

import { NamingConfig, ResourceTags } from './types.bicep'

// ============================================================================
// Parameters
// ============================================================================

@description('Resource location')
param location string

@description('API Management configuration settings')
param apiManagementConfig object

@description('Naming configuration')
param namingConfig NamingConfig

@description('Resource tags')
param tags ResourceTags

@description('APIM subnet resource ID')
param apimSubnetId string

@description('Application Insights resource ID')
param appInsightsId string

@description('Application Insights name')
param appInsightsName string

@description('Application Insights instrumentation key')
@secure()
param appInsightsInstrumentationKey string

// ============================================================================
// Variables
// ============================================================================

var apimName = '${namingConfig.namingPrefix}-apim-${namingConfig.uniqueSuffix}'

// ============================================================================
// Resources
// ============================================================================

// API Management Service (Infrastructure Only)
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: apiManagementConfig.skuName
    capacity: apiManagementConfig.skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: apiManagementConfig.publisherEmail
    publisherName: apiManagementConfig.publisherName
    notificationSenderEmail: apiManagementConfig.publisherEmail
    // Virtual network integration for Consumption tier is limited
    virtualNetworkConfiguration: apiManagementConfig.skuName == 'Consumption' ? null : {
      subnetResourceId: apimSubnetId
    }
    // Custom properties are only supported in non-Consumption tiers
    customProperties: apiManagementConfig.skuName == 'Consumption' ? {} : {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
    }
  }
}

// API Management Logger for Application Insights
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2023-09-01-preview' = {
  parent: apim
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
    isBuffered: true
    resourceId: appInsightsId
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('API Management service ID')
output apimId string = apim.id

@description('API Management service name')
output apimName string = apim.name

@description('API Management gateway URL')
output apimGatewayUrl string = apim.properties.gatewayUrl

@description('API Management portal URL')
output apimPortalUrl string = apiManagementConfig.skuName == 'Consumption' ? '' : apim.properties.developerPortalUrl

@description('API Management management URL')
output apimManagementUrl string = apiManagementConfig.skuName == 'Consumption' ? '' : apim.properties.managementApiUrl
