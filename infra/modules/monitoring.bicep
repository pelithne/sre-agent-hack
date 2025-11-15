// ============================================================================
// Monitoring Module for SRE Agent Hackathon Infrastructure
// ============================================================================
// This module creates the monitoring and observability infrastructure including:
// - Log Analytics workspace for centralized logging
// - Application Insights for application telemetry
// - Proper workspace configuration for Container Apps integration
// ============================================================================

targetScope = 'resourceGroup'

import { MonitoringConfig, NamingConfig, ResourceTags } from './types.bicep'

// ============================================================================
// Parameters
// ============================================================================

@description('Resource location')
param location string

@description('Monitoring configuration settings')
param monitoringConfig MonitoringConfig

@description('Naming configuration')
param namingConfig NamingConfig

@description('Resource tags')
param tags ResourceTags

// ============================================================================
// Variables
// ============================================================================

var logAnalyticsName = '${namingConfig.namingPrefix}-logs-${namingConfig.uniqueSuffix}'
var appInsightsName = '${namingConfig.namingPrefix}-ai-${namingConfig.uniqueSuffix}'

// ============================================================================
// Resources
// ============================================================================

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: monitoringConfig.logRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1 // Unlimited for workshop purposes
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: monitoringConfig.applicationType
  properties: {
    Application_Type: monitoringConfig.applicationType
    WorkspaceResourceId: logAnalytics.id
    RetentionInDays: monitoringConfig.logRetentionDays
    Request_Source: monitoringConfig.requestSource
    Flow_Type: monitoringConfig.flowType
    SamplingPercentage: monitoringConfig.samplingPercentage
    IngestionMode: 'LogAnalytics' // Modern mode for better integration
  }
}

// ============================================================================
// Outputs
// ============================================================================

@description('Log Analytics workspace resource ID')
output logAnalyticsId string = logAnalytics.id

@description('Log Analytics workspace name')
output logAnalyticsName string = logAnalytics.name

@description('Log Analytics workspace customer ID')
output logAnalyticsCustomerId string = logAnalytics.properties.customerId

@description('Application Insights resource ID')
output appInsightsId string = appInsights.id

@description('Application Insights name')
output appInsightsName string = appInsights.name

@description('Application Insights instrumentation key (contains sensitive data)')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('Log Analytics workspace shared key (contains sensitive data)')  
output logAnalyticsSharedKey string = logAnalytics.listKeys().primarySharedKey

@description('Application Insights connection string (contains sensitive data)')
output appInsightsConnectionString string = appInsights.properties.ConnectionString
