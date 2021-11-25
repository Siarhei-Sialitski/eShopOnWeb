param location string
param storageAccountConnectionString string
param appInsightsInstrumentationKey string
param functionAppServicePlanName string
param stockFunctionAppName string
param deliveryFunctionAppName string
param netFrameworkVersion string
param serviceBusConnectionString string
param databaseAccountConnectionString string
param queueName string

resource functionAppServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: functionAppServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource stockFunctionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: stockFunctionAppName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionAppServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ServiceBusConnection'
          value: serviceBusConnectionString
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        // Configure with Logic App Endpoint
        // {
        //   name: 'LogicAppEndpoint'
        //   value: ''
        // }
        {
          name: 'QueueName'
          value: queueName
        }
      ]
      netFrameworkVersion: netFrameworkVersion
    }
  }
}

resource deliveryFunctionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: deliveryFunctionAppName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionAppServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'CosmosDbConnectionString'
          value: databaseAccountConnectionString
        }
      ]
      netFrameworkVersion: netFrameworkVersion
    }
  }
}
