@description('The Azure region into which the resources should be deployed.')
param location string

@description('Azure Container Registry Name.')
param acrName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Azure Container Registry Tier.')
param acrSku string = 'Basic'

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false


resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

@description('Azure Container Registry Login Server.')
output catalogDatabaseConnectionString string = acr.properties.loginServer
