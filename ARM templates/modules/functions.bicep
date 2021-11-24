@description('The Azure region into which the resources should be deployed.')
param location string

@description('Storage Account Connection String')
param storageAccountConnectionString string

@description('Application Insight Instrumentation Key')
param appInsightsInstrumentationKey string

@description('Function App Service Plan Name.')
param functionAppServicePlanName string

@description('Stock Function App Name.')
param stockFunctionAppName string

@description('Delivery Function App Name.')
param deliveryFunctionAppName string

@description('.Net Framework Version.')
param netFrameworkVersion string

@description('Service Bus Connection String')
param serviceBusConnectionString string

@description('Cosmos Database Connection String')
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
          value: 'https://prod-00.northcentralus.logic.azure.com:443/workflows/14541d2799834df293d4a81ce13c9b8b/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=m0lBa3Y7Tu_iI3N_rW_HJPyhrikO7Sy8J-lI5Zus5wU'
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
