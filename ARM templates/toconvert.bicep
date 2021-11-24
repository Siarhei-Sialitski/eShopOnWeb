var uniqueSuffix = toLower(uniqueString(resourceGroup().id))
var appPlanName_var = 'demo-web-app-plan-${uniqueSuffix}'
var appName_var = 'demo-web-app-${uniqueSuffix}'
var registrySubscriptionId = 'CHANGETO-YOUR-SUBS-GUID-000000000000'
var registryResourceGroup = 'container-registry-resource-group'
var registryName = 'hompus'
var registryResourceId = resourceId(registrySubscriptionId, registryResourceGroup, 'Microsoft.ContainerRegistry/registries', registryName)

resource appPlanName 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: appPlanName_var
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appName 'Microsoft.Web/sites@2018-11-01' = {
  name: appName_var
  location: resourceGroup().location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appPlanName.id
  }
}

resource appName_web 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appName
  name: 'web'
  properties: {
    linuxFxVersion: 'DOCKER|hompus.azurecr.io/samples/nginx:latest'
  }
}

resource appName_appsettings 'Microsoft.Web/sites/config@2018-11-01' = {
  parent: appName
  name: 'appsettings'
  properties: {
    DOCKER_REGISTRY_SERVER_URL: reference(registryResourceId, '2019-05-01').loginServer
    DOCKER_REGISTRY_SERVER_USERNAME: listCredentials(registryResourceId, '2019-05-01').username
    DOCKER_REGISTRY_SERVER_PASSWORD: listCredentials(registryResourceId, '2019-05-01').passwords[0].value
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
  }
}