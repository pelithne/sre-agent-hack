// ============================================================================
// Identity Module for SRE Agent Hackathon Infrastructure
// ============================================================================
// This module creates the managed identity infrastructure including:
// - User-assigned managed identity for Container Apps
// - ACR pull role assignment for accessing container images
// - Secure identity configuration following Azure best practices
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

@description('Azure Container Registry name (optional, only needed for custom images from ACR)')
param acrName string = ''

// ============================================================================
// Variables
// ============================================================================

var managedIdentityName = '${namingConfig.namingPrefix}-identity'

// ============================================================================
// Resources
// ============================================================================

// User-assigned managed identity for Container App
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}

// Reference to existing ACR (created in Step 4 of the workshop)
resource existingAcr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = if (!empty(acrName)) {
  name: acrName
}

// Grant managed identity AcrPull permission to the ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(acrName)) {
  name: guid(managedIdentity.id, existingAcr.id, 'AcrPull')
  scope: existingAcr
  properties: {
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Managed identity resource ID')
output managedIdentityId string = managedIdentity.id

@description('Managed identity name')
output managedIdentityName string = managedIdentity.name

@description('Managed identity principal ID')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

@description('Managed identity client ID')
output managedIdentityClientId string = managedIdentity.properties.clientId

@description('ACR name (if provided)')
output acrName string = acrName

@description('Whether ACR integration is enabled')
output hasAcrIntegration bool = !empty(acrName)
