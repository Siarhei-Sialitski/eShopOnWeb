param environment string
param location string = resourceGroup().location
param secondaryLocation string = 'westus'
param appServicePlanName string = 'plan-applications-${environment}-${location}'
param appServicePlanSecondaryName string = 'plan-applications-${environment}-${secondaryLocation}'
param apiAppServicePlanName string = 'plan-api-${environment}-${location}'
param functionAppServicePlanName string = 'plan-functions-${environment}-${location}'
param webAppPrimaryInstanceName string = 'app-website-${environment}-${location}'
param webAppSecondaryInstanceName string = 'app-website-${environment}-${secondaryLocation}'
param apiAppName string = 'app-api-${environment}-${location}'
param stockFunctionAppName string = 'func-stock-${environment}-${location}'
param deliveryFunctionAppName string = 'func-delivery-${environment}-${location}'
param sku string = 'S1'
param currentStack string = 'dotnet'
param netFrameworkVersion string = 'v6.0'
param databaseAccountName string = 'cosmos-account-${environment}-${location}'
param storageAccountName string = 'st-account-${environment}-${location}'
param databaseName string = 'DeliveryOrders'

@description('List of containers in cosmos database')
param containers array = [
  {
    name: 'orders'
    partitionKey: '/id'
  }
]
param sqlServerName string = 'sql-applications-${environment}-${location}'

param sqlServerAdministratorName string

@secure()
param sqlServerAdministratorPassword string

param serviceBusNamespaceName string = 'sb-stock-${environment}-${location}'
param serviceBusQueueName string = 'sbq-orders-${environment}-${location}'
param ordersContainerName string = 'orders'
param containerRegistryName string = 'creshoponweb${environment}${location}'
param trafficManagerName string = 'traf-${environment}-${location}'
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
    sku: 'F1'
    appServicePlanName: apiAppServicePlanName
  }
}


module containerRegistry 'modules/containerregistry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    acrName: containerRegistryName
    acrAdminUserEnabled: true
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
    appName: apiAppName
    location: location
    servicePlanResourceId: linuxServicePlan.outputs.id
    kind: 'app,linux,container'
    dockerRegistryUrl: containerRegistry.outputs.loginServer
    dockerRegistryUserName: containerRegistry.outputs.username
    dockerRegistryPasssword: containerRegistry.outputs.password
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
    queueName: serviceBusQueueName
  }
}

module trafficManagerProfile 'modules/trafficmanager.bicep' = {
  name: 'trafficManagerProfile'
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
      // Secretes should be added here or manualy after function deploy when uri and key will be generated.
      // {
      //   name: 'DeliveryServiceConfiguration--FunctionBaseUrl'
      //   value: ''
      // }
      // {
      //   name: 'DeliveryServiceConfiguration--FunctionKey'
      //   value: ''
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
        value: 'https://${trafficManagerProfile.outputs.fqdn}/'
      }
      {
        name: 'baseUrls--ApiBase'
        value: 'https://${apiAppInstanse.outputs.applicationDefaultHostName}/api/'
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
        name: 'baseUrls--webBase'
        value: 'https://${trafficManagerProfile.outputs.fqdn}/'
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
