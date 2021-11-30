param location string
param appName string
param kind string
param appKeyVaultName string
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
      //linuxFxVersion: 'DOCKER|nginx'
      appCommandLine: ''
    }
    serverFarmId: servicePlanResourceId
  }
}

output applicationDefaultHostName string = application.properties.defaultHostName
output applicationId string = application.id
output applicationTenantId string = reference(application.id, '2018-02-01', 'Full').identity.tenantId
output applicationPrincipalId string = reference(application.id, '2018-02-01', 'Full').identity.principalId
