// ============================================================================
// Azure Container Registry Module for SRE Agent Hackathon Infrastructure
// ============================================================================
// This module creates an Azure Container Registry with:
// - Basic SKU for cost optimization
// - Admin user enabled for building and pushing images
// - Managed identity integration for Container Apps access
// ============================================================================

targetScope = 'resourceGroup'

import { NamingConfig, ResourceTags } from './types.bicep'

// ============================================================================
// Parameters
// ============================================================================

@description('Resource location')
param location string

@description('Naming configuration')
param namingConfig NamingConfig

@description('Resource tags')
param tags ResourceTags

@description('ACR SKU (Basic, Standard, Premium)')
@allowed(['Basic', 'Standard', 'Premium'])
param skuName string = 'Basic'

@description('Enable admin user for ACR (needed for building)')
param adminUserEnabled bool = true

// ============================================================================
// Variables
// ============================================================================

// Resource names - ensure minimum 5 characters for ACR name and avoid duplicates
var acrName = '${namingConfig.baseName}${namingConfig.environmentName}acr${namingConfig.uniqueSuffix}'

// ============================================================================
// Resources
// ============================================================================

// Azure Container Registry
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('ACR resource ID')
output acrId string = acr.id

@description('ACR name')
output acrName string = acr.name

@description('ACR login server')
output acrLoginServer string = acr.properties.loginServer

@description('ACR admin username')
output acrAdminUsername string = acr.name
