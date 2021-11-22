@description('The Azure region into which the resources should be deployed.')
param location string

@description('ServiceBus Namespace Name.')
param serviceBusNamespaceName string

@description('ServiceBus Queue Name.')
param serviceBusQueueName string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  parent: serviceBusNamespace
  name: serviceBusQueueName
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 10
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

@description('ServiceBus Connection String.')
output serviceBusConnectionString string = listKeys(resourceId('Microsoft.ServiceBus/namespaces/AuthorizationRules', serviceBusNamespaceName, 'RootManageSharedAccessKey'), '2015-08-01').primaryConnectionString
