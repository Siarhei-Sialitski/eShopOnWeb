@description('Environment name.')
param environment string

@description('Location of the resource.')
param location string = resourceGroup().location

@description('Location of the secondary resource.')
param secondaryLocation string = 'westus'

@description('App service name.')
@minLength(2)
param appServicePlanName string = 'plan-applications-${environment}-${location}'

@description('App service name.')
@minLength(2)
param appServicePlanSecondaryName string = 'plan-applications-${environment}-${secondaryLocation}'

@description('Api App service name.')
@minLength(2)
param apiAppServicePlanName string = 'plan-api-${environment}-${location}'

@description('Function App service plan name.')
@minLength(2)
param functionAppServicePlanName string = 'plan-functions-${environment}-${location}'

@description('Web app name.')
@minLength(2)
param webAppPrimaryInstanceName string = 'app-website-${environment}-${location}'

@description('Web app name.')
@minLength(2)
param webAppSecondaryInstanceName string = 'app-website-${environment}-${secondaryLocation}'

@description('Api app name.')
@minLength(2)
param apiAppName string = 'app-api-${environment}-${location}'

@description('Stock function app name.')
@minLength(2)
param stockFunctionAppName string = 'func-stock-${environment}-${location}'

@description('Delivery function app name.')
@minLength(2)
param deliveryFunctionAppName string = 'func-delivery-${environment}-${location}'

@description('The SKU of App Service Plan.')
param sku string = 'S1'

@description('Current stack')
param currentStack string = 'dotnet'

@description('DotNet framework version')
param netFrameworkVersion string = 'v6.0'

@description('Cosmos DB account name')
param databaseAccountName string = 'cosmos-account-${environment}-${location}'

@description('Blob account name')
param storageAccountName string = 'st-account-${environment}-${location}'

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
param sqlServerName string = 'sql-applications-${environment}-${location}'

@description('SQL Server Administrator name')
param sqlServerAdministratorName string

@description('SQL Server Administrator password')
param sqlServerAdministratorPassword string

@description('Service Bus Namespace name')
param serviceBusNamespaceName string = 'sb-stock-${environment}-${location}'

@description('Service Bus Namespace name')
param serviceBusQueueName string = 'sbq-orders-${environment}-${location}'

@description('Order Items blob container name')
param ordersContainerName string = 'orders'

@description('Container Registry Name')
param containerRegistryName string = 'creshoponweb${environment}${location}'

@description('Traffic Manager Name')
param trafficManagerName string = 'traf-${environment}-${location}'

@description('Traffic Manager Dns')
param trafficManagerDns string = 'eshoponwebss'

var databaseAccountNameFormatted = toLower(databaseAccountName)
var storageAccountNameFormatted = take(replace(toLower(storageAccountName), '-', ''), 24)
var webAppkeyVaultName = 'kvwebeshop${environment}${location}'
var apiAppkeyVaultName = 'kvapieshop${environment}${location}'
var appInsightsName = 'appi-${environment}-${location}'

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

module primaryServicePlan 'modules/serviceplan.bicep' = {
  name: 'primaryServicePlan'
  params:{
    location: location
    sku: sku
    appServicePlanName: appServicePlanName
    autoscaleEnabled: true
  }
}

module secondaryServicePlan 'modules/serviceplan.bicep' = {
  name: 'secondaryServicePlan'
  params:{
    location: secondaryLocation
    sku: sku
    appServicePlanName: appServicePlanSecondaryName
    autoscaleEnabled: true
  }
}

module linuxServicePlan 'modules/linuxserviceplan.bicep' = {
  name: 'linuxServicePlan'
  params:{
    location: location
    sku: 'P1V3'
    appServicePlanName: apiAppServicePlanName
  }
}

module webAppPrimaryInstanse 'modules/application.bicep' = {
  name: 'webAppPrimaryInstance'
  params: {
    appKeyVaultName: webAppkeyVaultName
    applicationStack: currentStack
    appName: webAppPrimaryInstanceName
    location: location
    netFrameworkVersion: netFrameworkVersion
    servicePlanResourceId: primaryServicePlan.outputs.id
    kind: 'windows'
  }
}

module webAppSecondaryInstanse 'modules/application.bicep' = {
  name: 'webAppSecondaryInstance'
  params: {
    appKeyVaultName: webAppkeyVaultName
    applicationStack: currentStack
    appName: webAppSecondaryInstanceName
    location: secondaryLocation
    netFrameworkVersion: netFrameworkVersion
    servicePlanResourceId: secondaryServicePlan.outputs.id
    kind: 'windows'
  }
}

module apiAppInstanse 'modules/containerapp.bicep' = {
  name: 'apiAppInstanse'
  params: {
    appKeyVaultName: apiAppkeyVaultName
    applicationStack: currentStack
    appName: apiAppName
    location: location
    netFrameworkVersion: netFrameworkVersion
    servicePlanResourceId: linuxServicePlan.outputs.id
    kind: 'app,container,windows'
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

module containerRegistry 'modules/containerregistry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    acrName: containerRegistryName
  }
}

module trafficManagerProfile 'modules/trafficmanager.bicep' = {
  name: 'trafficMAnagerProfile'
  params:{
    secondaryWebAppId: webAppSecondaryInstanse.outputs.applicationId
    secondaryEndpointName: 'secondary'
    primaryEndpointName: 'primary'
    uniqueDnsName: trafficManagerDns
    trafficManagerName: trafficManagerName
    primaryWebAppId: webAppPrimaryInstanse.outputs.applicationId
  }
}

module webAppKeyVault 'modules/keyvault.bicep' = {
  name: 'webAppKeyVault'
  params: {
    location: location
    keyVaultName: webAppkeyVaultName
    tenantId: webAppPrimaryInstanse.outputs.applicationTenantId
    objectId: webAppPrimaryInstanse.outputs.applicationPrincipalId
    secrets: [
      {
        name: 'ConnectionStrings--CatalogConnection'
        value: sqlServer.outputs.catalogDatabaseConnectionString
      }
      {
        name: 'ConnectionStrings--IdentityConnection'
        value: sqlServer.outputs.identityDatabaseConnectionString
      }
      // {
      //   name: 'DeliveryServiceConfiguration--FunctionBaseUrl'
      //   value: 'https://func-delivery-prod-westeurope.azurewebsites.net/api/'
      // }
      // {
      //   name: 'DeliveryServiceConfiguration--FunctionKey'
      //   value: 'DNH0yIflYfVjliNwcnxQKqMu4VJFiPgAR8340HDAPdGa4yrTqTQTfQ=='
      // }
      {
        name: 'ApplicationInsights--InstrumentationKey'
        value: util.outputs.appInsightsInstrumentationKey
      }
      {
        name: 'WarehouseServiceConfiguration--ConnectionString'
        value: serviceBus.outputs.serviceBusConnectionString
      }
      {
        name: 'WarehouseServiceConfiguration--QueueName'
        value: serviceBusQueueName
      }
      {
        name: 'baseUrls--WebBase'
        value: trafficManagerProfile.outputs.fqdn
      }
      {
        name: 'baseUrls--ApiBase'
        value: apiAppInstanse.outputs.applicationDefaultHostName
      }
    ]
    additionalPolicies: [
      {
        name: 'secondaryWebApp'
        tenantId: webAppSecondaryInstanse.outputs.applicationTenantId
        objectId: webAppSecondaryInstanse.outputs.applicationPrincipalId
      }
    ]
  }
}

module apiAppKeyVault 'modules/keyvault.bicep' = {
  name: 'apiAppKeyVault'
  params: {
    location: location
    keyVaultName: apiAppkeyVaultName
    tenantId:apiAppInstanse.outputs.applicationTenantId
    objectId:apiAppInstanse.outputs.applicationPrincipalId
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
        value: webAppPrimaryInstanse.outputs.applicationDefaultHostName
      }
      {
        name: 'baseUrls--webBase2'
        value: webAppSecondaryInstanse.outputs.applicationDefaultHostName
      }
      {
        name: 'ApplicationInsights--InstrumentationKey'
        value: util.outputs.appInsightsInstrumentationKey
      }
    ]
    additionalPolicies: [
    ]
    
  }
}
