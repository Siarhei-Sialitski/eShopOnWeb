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

// @description('Service principal id.')
// param servicePrincipalId string

@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '7f951dda-4ed3-4680-a7ca-43fe172d538d' // Acr Pull
])
param roleAcrPull string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'


resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  // tags: {
  //   displayName: 'Container Registry'
  //   'container.registry': acrName
  // }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

// resource assignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(resourceGroup().id, acrName, servicePrincipalId, 'AssignAcrPullToAks')
//   scope: acr
//   properties: {
//     description: 'Assign AcrPull role to AKS'
//     principalId: servicePrincipalId
//     principalType: 'ServicePrincipal'
//     roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleAcrPull}'
//   }
// }

@description('Azure Container Registry Login Server.')
output loginServer string = acr.properties.loginServer

output username string = acr.listCredentials().username
output password string = acr.listCredentials().passwords[0].value
