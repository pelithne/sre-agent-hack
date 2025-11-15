// ============================================================================
// API Management Configuration Module (Phase 2)
// ============================================================================
// This module configures APIs and backends on an existing APIM service.
// The APIM service itself is deployed in Phase 1.
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// Parameters
// ============================================================================

@description('Container App URL for backend service')
param containerAppUrl string

@description('Existing APIM service name')
param apimName string

@description('API Management configuration settings')
param apiManagementConfig object

// ============================================================================
// Resources
// ============================================================================

// Reference existing APIM service
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' existing = {
  name: apimName
}

// API Backend
resource apimBackend 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  parent: apim
  name: 'workshop-api-backend'
  properties: {
    description: 'Workshop API Container App Backend'
    url: containerAppUrl
    protocol: 'http'
    resourceId: containerAppUrl
  }
}

// API Definition
resource apimApi 'Microsoft.ApiManagement/service/apis@2023-09-01-preview' = {
  parent: apim
  name: 'workshop-api'
  properties: {
    displayName: apiManagementConfig.apiDisplayName
    description: apiManagementConfig.apiDescription
    path: apiManagementConfig.apiPathPrefix
    protocols: ['https']
    serviceUrl: containerAppUrl
    subscriptionRequired: true
  }
}

// API Policy to set backend
resource apimApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-09-01-preview' = {
  parent: apimApi
  name: 'policy'
  properties: {
    value: '''
<policies>
  <inbound>
    <base />
    <set-backend-service backend-id="workshop-api-backend" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
'''
  }
}

// Health Check Operation
resource healthOperation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: apimApi
  name: 'health-check'
  properties: {
    displayName: 'Health Check'
    method: 'GET'
    urlTemplate: '/health'
    description: 'Returns the health status of the API'
    responses: [
      {
        statusCode: 200
        description: 'Health check successful'
        representations: [
          {
            contentType: 'application/json'
          }
        ]
      }
    ]
  }
}

// Items CRUD Operations would go here (simplified for now)

// ============================================================================
// Outputs
// ============================================================================

@description('API ID')
output apiId string = apimApi.id

@description('API name')
output apiName string = apimApi.name

@description('API URL')
output apiUrl string = '${apim.properties.gatewayUrl}/${apiManagementConfig.apiPathPrefix}'

@description('Backend ID')
output backendId string = apimBackend.id
