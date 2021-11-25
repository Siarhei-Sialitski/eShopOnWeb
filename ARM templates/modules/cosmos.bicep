param location string
param databaseAccountName string
param databaseName string
param containers array

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: databaseAccountName
  location: location
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/apis/databases@2016-03-31' = {
  name: '${databaseAccountName}/sql/${databaseName}'
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: '400'
    }
  }
  dependsOn: [
    databaseAccount
  ]
}

resource containere 'Microsoft.DocumentDb/databaseAccounts/apis/databases/containers@2016-03-31' = [for item in containers: {
  name: '${databaseAccountName}/sql/${databaseName}/${item.name}'
  properties: {
    resource: {
      id: item.name
      partitionKey: {
        paths: [
          item.partitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'Consistent'
      }      
    }
    options: {       
    }
  }
  dependsOn: [
    database
  ]
}]

output databaseAccountConnectionString string = 'AccountEndpoint=https://${databaseAccountName}.documents.azure.com:443/;AccountKey=${listKeys(databaseAccount.id, '2019-08-01').primaryMasterKey};'
