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
        {
          name: 'LogicAppEndpoint'
          value: 'https://prod-81.westeurope.logic.azure.com:443/workflows/c2647276ccec4a23b5383343a0b028b8/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=Ko7uD2s5dRxr9a2ymLTbKg_A3g26j_8WqpLYNaZu0JQ'
        }
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
