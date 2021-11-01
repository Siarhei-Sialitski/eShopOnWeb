@description('The Azure region into which the resources should be deployed.')
param location string

@description('Website Application Key Vault Name.')
param keyVaultName string

@description('List of secrets')
param secrets array

@description('Website Application Tenant Id.')
param tenantId string

@description('Website Application Principal Id.')
param principalId string


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
        objectId: principalId
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

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2016-10-01' = [for secret in secrets: {
  parent: keyVault
  name: secret.Name
  properties: {
    value: secret.Value
  }
}]
