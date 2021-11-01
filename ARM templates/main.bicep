@description('Name of the resource group for the resource.')
param resourceGroupName string = resourceGroup().name

@description('Location of the resource.')
param location string = resourceGroup().location

@description('App service name.')
@minLength(2)
param appServicePlanName string = '${resourceGroupName}-appServicePlan'

@description('Function App service plan name.')
@minLength(2)
param functionAppServicePlanName string = '${resourceGroupName}-functionAppServicePlan'

@description('Web app name.')
@minLength(2)
param webAppName string = '${resourceGroupName}-webApp'

@description('Api app name.')
@minLength(2)
param apiAppName string = '${resourceGroupName}-apiApp'

@description('Stock function app name.')
@minLength(2)
param stockFunctionAppName string = '${resourceGroupName}-stockFunctionApp'

@description('Delivery function app name.')
@minLength(2)
param deliveryFunctionAppName string = '${resourceGroupName}-deliveryFunctionApp'

@description('The SKU of App Service Plan.')
param sku string = 'F1'

@description('Current stack')
param currentStack string = 'dotnet'

@description('DotNet framework version')
param netFrameworkVersion string = 'v5.0'

@description('Cosmos DB account name')
param databaseAccountName string = '${resourceGroupName}-cosmosAccount-ss'

@description('Blob account name')
param storageAccountName string = '${resourceGroupName}blobAccount'

@description('Core (SQL) database name')
param databaseName string = 'DeliveryOrders'

@description('List of containers in cosmos database')
param containers array = [
  {
    name: 'orders'
    partitionKey: '/id'
  }
]

@description('SQL Server name')
param sqlServerName string = '${resourceGroupName}-sqlServer-ss'

@description('SQL Server Administrator name')
param sqlServerAdministratorName string

@description('SQL Server Administrator password')
param sqlServerAdministratorPassword string

@description('Service Bus Namespace name')
param serviceBusNamespaceName string = '${resourceGroupName}-servicebusnamespace-ss'

@description('Service Bus Namespace name')
param serviceBusQueueName string = 'OrderItems'

@description('Order Items blob container name')
param ordersContainerName string = 'orders'

var databaseAccountNameFormatted = toLower(databaseAccountName)
var storageAccountNameFormatted = replace(toLower(storageAccountName), '-', '')
var webAppkeyVaultName = toLower('WebSiteKeyVaultProd')
var apiAppkeyVaultName = toLower('ApiKeyVaultProd')
var appInsightsName = '${resourceGroupName}-ApplicationInsights'

module util 'modules/util.bicep' = {
  name: 'util'
  params: {
    location: location
    appInsightsName: appInsightsName
  }
}

module sqlServer 'modules/sqlserver.bicep' = {
  name: 'sqlserver'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlServerAdministratorName: sqlServerAdministratorName
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
  }
}

module appServices 'modules/applications.bicep' = {
  name: 'appServices'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    sku : sku
    webAppName: webAppName 
    apiAppName: apiAppName
    webAppKeyVaultName: webAppkeyVaultName 
    apiAppKeyVaultName: apiAppkeyVaultName
    netFrameworkVersion: netFrameworkVersion
    applicationsStack: currentStack
  }
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountNameFormatted
    containerName: ordersContainerName
  }
}

module cosmosDatabase 'modules/cosmos.bicep' = {
  name: 'cosmosDatabase'
  params: {
    location: location
    containers: containers
    databaseAccountName: databaseAccountNameFormatted
    databaseName: databaseName
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'serviceBus'
  params: {
    location: location
    serviceBusNamespaceName: serviceBusNamespaceName
    serviceBusQueueName: serviceBusQueueName
  }
}

module functions 'modules/functions.bicep' = {
  name: 'functions'
  params: {
    location: location
    storageAccountConnectionString: storage.outputs.storageAccountConnectionString
    stockFunctionAppName: stockFunctionAppName
    serviceBusConnectionString: serviceBus.outputs.serviceBusConnectionString
    functionAppServicePlanName: functionAppServicePlanName
    databaseAccountConnectionString: cosmosDatabase.outputs.databaseAccountConnectionString
    netFrameworkVersion: netFrameworkVersion
    appInsightsInstrumentationKey: util.outputs.appInsightsInstrumentationKey 
    deliveryFunctionAppName: deliveryFunctionAppName
  }
}

module webAppKeyVault 'modules/keyvault.bicep' = {
  name: 'webAppKeyVault'
  params: {
    location: location
    keyVaultName: webAppkeyVaultName
    secrets: [
      {
        name: 'ConnectionStrings--CatalogConnection'
        value: sqlServer.outputs.catalogDatabaseConnectionString
      }
      {
        name: 'ConnectionStrings--IdentityConnection'
        value: sqlServer.outputs.identityDatabaseConnectionString
      }
      {
        name: 'webBase'
        value: appServices.outputs.webApplicationDefaultHostName
      }
      {
        name: 'DeliveryOrderReserverConfiguration--FunctionBaseUrl'
        value: ''
      }
      {
        name: 'DeliveryOrderReserverConfiguration--FunctionKey'
        value: ''
      }
      {
        name: 'ApplicationInsights--InstrumentationKey'
        value: util.outputs.appInsightsInstrumentationKey
      }
      {
        name: 'OrderItemsReserverConfig--ConnectionString'
        value: serviceBus.outputs.serviceBusConnectionString
      }
      {
        name: 'OrderItemsReserverConfig--QueueName'
        value: serviceBusQueueName
      }
    ]
    principalId: appServices.outputs.webApplicationPrincipalId
    tenantId: appServices.outputs.webApplicationTenantId
  }
}

module apiAppKeyVault 'modules/keyvault.bicep' = {
  name: 'apiAppKeyVault'
  params: {
    location: location
    keyVaultName: apiAppkeyVaultName
    secrets: [
      {
        name: 'ConnectionStrings--CatalogConnection'
        value: sqlServer.outputs.catalogDatabaseConnectionString
      }
      {
        name: 'ConnectionStrings--IdentityConnection'
        value: sqlServer.outputs.identityDatabaseConnectionString
      }
      {
        name: 'baseUrls--webBase1'
        value: appServices.outputs.webApplicationDefaultHostName
      }
      {
        name: 'baseUrls--webBase2'
        value: appServices.outputs.webApplicationDefaultHostName
      }
      {
        name: 'ApplicationInsights--InstrumentationKey'
        value: util.outputs.appInsightsInstrumentationKey
      }
    ]
    principalId: appServices.outputs.apiApplicationPrincipalId
    tenantId: appServices.outputs.apiApplicationTenantId
  }
}
