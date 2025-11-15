// ============================================================================
// Simplified Container Apps Module (without VNet integration)
// ============================================================================

targetScope = 'resourceGroup'

import { ContainerAppConfig, NamingConfig, ResourceTags } from './types.bicep'

// ============================================================================
// Parameters
// ============================================================================

@description('Resource location')
param location string

@description('Container App configuration settings')
param containerAppConfig ContainerAppConfig

@description('Naming configuration')
param namingConfig NamingConfig

@description('Resource tags')
param tags ResourceTags

@description('Log Analytics workspace customer ID')
param logAnalyticsCustomerId string

@description('Log Analytics workspace shared key')
@secure()
param logAnalyticsSharedKey string

@description('Managed identity resource ID')
param managedIdentityId string

@description('PostgreSQL server FQDN')
param postgresServerFqdn string

@description('PostgreSQL database name')
param postgresDatabaseName string

@description('PostgreSQL admin username')
param postgresAdminUsername string

@description('PostgreSQL admin password')
@secure()
param postgresAdminPassword string

// ============================================================================
// Variables
// ============================================================================

var targetPort = 8080

// Resource names
var containerAppEnvName = '${namingConfig.namingPrefix}-${namingConfig.environmentName}-cae-${namingConfig.uniqueSuffix}'
var containerAppName = '${namingConfig.namingPrefix}-${namingConfig.environmentName}-ca-${namingConfig.uniqueSuffix}'

// ============================================================================
// Resources
// ============================================================================

// Container Apps Environment (simplified without VNet)
resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
    // No VNet configuration for faster provisioning
    zoneRedundant: false
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    environmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'http'
        allowInsecure: false
        corsPolicy: {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
          allowedHeaders: ['*']
        }
      }
      secrets: [
        {
          name: 'postgres-password'
          value: postgresAdminPassword
        }
      ]
    }
    template: {
      revisionSuffix: 'v1'
      containers: [
        {
          name: 'api'
          image: containerAppConfig.image
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'POSTGRES_HOST'
              value: postgresServerFqdn
            }
            {
              name: 'POSTGRES_DATABASE'
              value: postgresDatabaseName
            }
            {
              name: 'POSTGRES_USERNAME'
              value: postgresAdminUsername
            }
            {
              name: 'POSTGRES_PASSWORD'
              secretRef: 'postgres-password'
            }
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Container Apps Environment resource ID')
output containerAppEnvironmentId string = containerAppEnv.id

@description('Container Apps Environment name')
output containerAppEnvironmentName string = containerAppEnv.name

@description('Container App resource ID')
output containerAppId string = containerApp.id

@description('Container App name')
output containerAppName string = containerApp.name

@description('Container App FQDN')
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn

@description('Container App URL')
output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
