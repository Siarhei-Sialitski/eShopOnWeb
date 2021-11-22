@description('The Azure region into which the resources should be deployed.')
param location string

@description('Application Insights Name.')
param appInsightsName string

resource appInsights 'Microsoft.Insights/components@2015-05-01' = {
  name: appInsightsName
  kind: 'web'
  location: location
  properties: {
    Application_Type: 'web'
  }
}

@description('Application Insights Instrumentation Key.')
output appInsightsInstrumentationKey string = reference(appInsights.id, '2015-05-01').InstrumentationKey
