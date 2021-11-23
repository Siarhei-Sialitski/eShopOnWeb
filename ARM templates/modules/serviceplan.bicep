@description('The Azure region into which the resources should be deployed.')
param location string

@description('Application Service Name.')
param appServicePlanName string

@description('Application Service Sku.')
param sku string

@description('Auto Scale Enabled.')
param autoscaleEnabled bool

resource applicationsServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  location: location
  name: appServicePlanName
  sku: {
    name: sku
  }
}

resource settingName 'Microsoft.Insights/autoscalesettings@2014-04-01' = {
  name: '${appServicePlanName}-autoscale-setting'
  location: location
  properties: {
    profiles: [
      {
        name: 'DefaultAutoscaleProfile'
        capacity: {
          minimum: '1'
          maximum: '2'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: applicationsServicePlan.id
              timeGrain: 'PT5M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 60
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ExactCount'
              value: '2'
              cooldown: 'PT10M'
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: applicationsServicePlan.id
              timeGrain: 'PT5M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ExactCount'
              value: '1'
              cooldown: 'PT10M'
            }
          }
        ]
      }
    ]
    enabled: autoscaleEnabled
    targetResourceUri: applicationsServicePlan.id
  }
}

@description('Service Plan Resource Id.')
output id string = applicationsServicePlan.id
