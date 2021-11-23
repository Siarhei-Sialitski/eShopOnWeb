@description('The Azure region into which the resources should be deployed.')
param location string

@description('Website Application Key Vault Name.')
param keyVaultName string

@description('List of secrets')
param secrets array

@description('TenantId')
param tenantId string 

@description('Object Id')
param objectId string

@description('List of additional policies')
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
