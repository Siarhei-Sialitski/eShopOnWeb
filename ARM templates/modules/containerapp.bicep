@description('The Azure region into which the resources should be deployed.')
param location string

@description('Web Application Name.')
param appName string

@description('Application kind')
param kind string

@description('Web Application Key Vault Name.')
param appKeyVaultName string

@description('.Net Framework version.')
param netFrameworkVersion string

@description('Application Stack.')
param applicationStack string

@description('Service Plan Resoucre Id.')
param servicePlanResourceId string

resource application 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'keyVaultName'
          value: appKeyVaultName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://mcr.microsoft.com'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: ''
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: ''
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      appCommandLine: ''
      netFrameworkVersion: netFrameworkVersion
      windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
    }
    serverFarmId: servicePlanResourceId
  }
}

@description('Application Default Host Name.')
output applicationDefaultHostName string = application.properties.defaultHostName

@description('Application Resource Id.')
output applicationId string = application.id

@description('Application Tenant Id.')
output applicationTenantId string = reference(application.id, '2018-02-01', 'Full').identity.tenantId

@description('Application Principal Id.')
output applicationPrincipalId string = reference(application.id, '2018-02-01', 'Full').identity.principalId
