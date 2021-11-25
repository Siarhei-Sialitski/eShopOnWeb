param location string
param appName string
param kind string
param appKeyVaultName string
param netFrameworkVersion string
param applicationStack string
param servicePlanResourceId string

resource application 'Microsoft.Web/sites@2020-06-01' = {
  name: appName
  identity: {
    type: 'SystemAssigned'
  }
  kind: kind
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'keyVaultName'
          value: appKeyVaultName
        }
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: applicationStack
        }
      ]
      netFrameworkVersion: netFrameworkVersion
    }
    serverFarmId: servicePlanResourceId
  }
}

output applicationDefaultHostName string = application.properties.defaultHostName
output applicationId string = application.id
output applicationTenantId string = reference(application.id, '2018-02-01', 'Full').identity.tenantId
output applicationPrincipalId string = reference(application.id, '2018-02-01', 'Full').identity.principalId
