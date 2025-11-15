// Minimal Container Apps test deployment
param location string = resourceGroup().location

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'test-env'
  location: location
  properties: {
    zoneRedundant: false
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'test-app'
  location: location
  properties: {
    environmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        transport: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'hello-world'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
