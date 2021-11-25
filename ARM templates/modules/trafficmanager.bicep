param trafficManagerName string
param uniqueDnsName string
param primaryEndpointName string
param primaryWebAppId string
param secondaryEndpointName string
param secondaryWebAppId string

resource trafficManagerProfile 'Microsoft.Network/trafficManagerProfiles@2018-08-01' = {
  name: trafficManagerName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Geographic'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
    }
    endpoints: [
      {
        name: primaryEndpointName
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: primaryWebAppId
          endpointStatus: 'Enabled'
          geoMapping: [
            'GEO-EU'
            'GEO-ME'
            'GEO-AS'
            'GEO-AF'
          ]
        }
      }
      {
        name: secondaryEndpointName
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: secondaryWebAppId
          endpointStatus: 'Enabled'
          geoMapping: [
            'GEO-NA'
            'GEO-SA'
            'GEO-AP'
          ]
        }
      }
    ]
  }
}

output fqdn string = trafficManagerProfile.properties.dnsConfig.fqdn
