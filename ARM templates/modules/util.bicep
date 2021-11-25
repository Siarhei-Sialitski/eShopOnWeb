param location string
param appInsightsName string

resource appInsights 'Microsoft.Insights/components@2015-05-01' = {
  name: appInsightsName
  kind: 'web'
  location: location
  properties: {
    Application_Type: 'web'
  }
}

output appInsightsInstrumentationKey string = reference(appInsights.id, '2015-05-01').InstrumentationKey
