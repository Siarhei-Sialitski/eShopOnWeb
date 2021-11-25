param location string
param keyVaultName string
param secrets array
param tenantId string 
param objectId string
param additionalPolicies array


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: {
    displayName: keyVaultName
  }
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = [for policy in additionalPolicies: {  
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies:[
      {
        tenantId: policy.tenantId
        objectId: policy.objectId
        permissions: {
          keys: [
          'get'
          ]
        secrets: [
          'list'
          'get'
          ]
        }  
      }
    ]
  }
}]

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = [for secret in secrets: {
  parent: keyVault
  name: secret.Name
  properties: {
    value: secret.Value
  }
}]
