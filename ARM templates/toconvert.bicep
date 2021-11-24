param subscriptionId string
param name string
param location string
param hostingPlanName string
param serverFarmResourceGroup string
param alwaysOn bool
param sku string
param skuCode string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param windowsFxVersion string
param dockerRegistryUrl string
param dockerRegistryUsername string

@secure()
param dockerRegistryPassword string
param dockerRegistryStartupCommand string

resource name_resource 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      windowsFxVersion: windowsFxVersion
      appCommandLine: dockerRegistryStartupCommand
      alwaysOn: alwaysOn
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: false
  }
  dependsOn: [
    hostingPlanName_resource
  ]
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2018-11-01' = {
  name: hostingPlanName
  location: location
  kind: 'windows'
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    hyperV: true
  }
  sku: {
    Tier: sku
    Name: skuCode
  }
  dependsOn: []
}