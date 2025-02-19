param location string
param sqlServerName string
param sqlServerAdministratorName string
param sqlServerAdministratorPassword string

resource sqlServer 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlServerAdministratorName
    administratorLoginPassword: sqlServerAdministratorPassword
  }
}

resource catalogDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: '${sqlServerName}-Catalog'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource identityDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: '${sqlServerName}-Identity'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallrules@2021-02-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output catalogDatabaseConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlServerName}-Catalog;Persist Security Info=False;User ID=${sqlServerAdministratorName};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
output identityDatabaseConnectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlServerName}-Identity;Persist Security Info=False;User ID=${sqlServerAdministratorName};Password=${sqlServerAdministratorPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
