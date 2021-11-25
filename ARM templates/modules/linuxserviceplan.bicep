param location string
param appServicePlanName string
param sku string

resource applicationsServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  location: location
  name: appServicePlanName
  kind: 'linux'
  sku: {
    name: sku
  }
  properties: {
    reserved: true
  }
}

output id string = applicationsServicePlan.id
