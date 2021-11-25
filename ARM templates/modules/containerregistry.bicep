param location string
param acrName string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

param acrAdminUserEnabled bool = false



resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output loginServer string = acr.properties.loginServer
output username string = acr.listCredentials().username
output password string = acr.listCredentials().passwords[0].value
