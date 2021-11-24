@description('The Azure region into which the resources should be deployed.')
param location string

@description('Application Service Name.')
param appServicePlanName string

@description('Application Service Sku.')
param sku string

resource applicationsServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  location: location
  name: appServicePlanName
  kind: 'windows'
  sku: {
    name: sku
  }
}

@description('Service Plan Resource Id.')
output id string = applicationsServicePlan.id
