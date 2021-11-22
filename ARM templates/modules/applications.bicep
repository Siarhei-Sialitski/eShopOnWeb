@description('The Azure region into which the resources should be deployed.')
param location string

@description('Application Service Name.')
param appServicePlanName string

@description('Application Service Sku.')
param sku string

@description('Web Application Name.')
param webAppName string

@description('Api Application Service Name.')
param apiAppName string

@description('Web Application Key Vault Name.')
param webAppKeyVaultName string

@description('Api Application Key Vault Name.')
param apiAppKeyVaultName string

@description('.Net Framework version.')
param netFrameworkVersion string

@description('Applications Stack.')
param applicationsStack string

resource applicationsServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  location: location
  name: appServicePlanName
  sku: {
    name: sku
  }
}

resource webApplication 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'keyVaultName'
          value: webAppKeyVaultName
        }
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: applicationsStack
        }
      ]
      netFrameworkVersion: netFrameworkVersion
    }
    serverFarmId: applicationsServicePlan.id
  }
}

resource apiApplication 'Microsoft.Web/sites@2020-06-01' = {
  name: apiAppName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'keyVaultName'
          value: apiAppKeyVaultName
        }
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: applicationsStack
        }
      ]
      netFrameworkVersion: netFrameworkVersion
    }
    serverFarmId: applicationsServicePlan.id
  }
}

@description('Web Application Default Host Name.')
output webApplicationDefaultHostName string = webApplication.properties.defaultHostName

@description('Web Application Tenant Id.')
output webApplicationTenantId string = reference(webApplication.id, '2018-02-01', 'Full').identity.tenantId

@description('Web Application Principal Id.')
output webApplicationPrincipalId string = reference(webApplication.id, '2018-02-01', 'Full').identity.principalId

@description('Api Application Tenant Id.')
output apiApplicationTenantId string = reference(apiApplication.id, '2018-02-01', 'Full').identity.tenantId

@description('Api Application Principal Id.')
output apiApplicationPrincipalId string = reference(apiApplication.id, '2018-02-01', 'Full').identity.principalId
