@description('The Azure region into which the resources should be deployed.')
param location string

@description('Web Application Name.')
param appName string

@description('Application kind')
param kind string

@description('Web Application Key Vault Name.')
param appKeyVaultName string

@description('Service Plan Resoucre Id.')
param servicePlanResourceId string

param dockerRegistryPasssword string
param dockerRegistryUrl string
param dockerRegistryUserName string


resource application 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  kind: kind
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
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPasssword
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUserName
        }
      ]
      linuxFxVersion: 'DOCKER|nginx'
      appCommandLine: ''
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
