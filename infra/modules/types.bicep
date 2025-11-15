// ============================================================================
// Shared Type Definitions for SRE Agent Hackathon Infrastructure
// ============================================================================
// This file contains user-defined types that are shared across modules
// to ensure consistency and type safety in parameter passing.
// ============================================================================

@export()
@description('Network configuration settings')
type NetworkConfig = {
  @description('Virtual network address space')
  vnetAddressPrefix: string

  @description('Container Apps subnet address prefix')
  containerAppsSubnetPrefix: string

  @description('PostgreSQL subnet address prefix') 
  postgresSubnetPrefix: string

  @description('API Management subnet address prefix')
  apimSubnetPrefix: string
}

@export()
@description('Naming configuration for resources')
type NamingConfig = {
  @description('Base name for resources')
  baseName: string

  @description('Environment name (dev, staging, prod)')
  environmentName: string

  @description('Unique suffix for resource names')
  uniqueSuffix: string

  @description('Common naming prefix')
  namingPrefix: string
}

@export()
@description('Database configuration settings')
type DatabaseConfig = {
  @description('PostgreSQL administrator username')
  adminUsername: string

  @description('PostgreSQL administrator password')
  @secure()
  adminPassword: string

  @description('Database name to create')
  databaseName: string

  @description('PostgreSQL server SKU')
  sku: string

  @description('Storage size in MB')
  storageSizeGB: int

  @description('Backup retention days')
  backupRetentionDays: int

  @description('High availability mode')
  highAvailability: 'Disabled' | 'ZoneRedundant' | 'SameZone'
}

@export()
@description('Container application configuration')
type ContainerAppConfig = {
  @description('Container image to deploy')
  image: string

  @description('Number of CPU cores (0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0)')
  cpu: string

  @description('Memory allocation (0.5Gi, 1Gi, 1.5Gi, 2Gi, 3Gi, 3.5Gi, 4Gi)')
  memory: string

  @description('Minimum number of replicas')
  minReplicas: int

  @description('Maximum number of replicas')
  maxReplicas: int

  @description('Target port for the container')
  targetPort: int

  @description('Environment variables for the container')
  environmentVariables: array
}

@export()
@description('API Management configuration')
type ApiManagementConfig = {
  @description('APIM SKU name')
  skuName: 'Consumption' | 'Developer' | 'Basic' | 'Standard' | 'Premium'

  @description('APIM SKU capacity')
  skuCapacity: int

  @description('Publisher name')
  publisherName: string

  @description('Publisher email')
  publisherEmail: string

  @description('API path prefix')
  apiPathPrefix: string

  @description('API display name')
  apiDisplayName: string

  @description('API description')
  apiDescription: string
}

@export()
@description('Monitoring configuration')
type MonitoringConfig = {
  @description('Log Analytics workspace retention in days')
  logRetentionDays: int

  @description('Application Insights application type')
  applicationType: 'web' | 'other'

  @description('Enable request source tracking')
  requestSource: 'rest'

  @description('Enable flow type tracking')
  flowType: 'Bluefield'

  @description('Sampling percentage for Application Insights')
  samplingPercentage: int
}

@export()
@description('Common resource tags')
type ResourceTags = {
  Environment: string
  Project: string
  ManagedBy: string
  *: string
}

@export()
@description('Subnet configuration')
type SubnetConfig = {
  @description('Subnet name')
  name: string

  @description('Subnet address prefix')
  addressPrefix: string

  @description('Service delegation configuration')
  delegation: {
    @description('Delegation name')
    delegationName: string
    @description('Service name for delegation')
    serviceName: string
  }?
}

@export()
@description('Output configuration for inter-module communication')
type ModuleOutputs = {
  @description('Resource group location')
  location: string

  @description('Virtual network resource ID')
  vnetId: string

  @description('Subnet resource IDs')
  subnetIds: {
    containerApps: string
    postgres: string
    apim: string
  }

  @description('Log Analytics workspace resource ID') 
  logAnalyticsId: string

  @description('Application Insights resource ID')
  appInsightsId: string

  @description('Managed identity resource ID')
  managedIdentityId: string

  @description('Managed identity principal ID')
  managedIdentityPrincipalId: string
}
