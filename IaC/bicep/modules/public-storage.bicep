@description('The Azure region for the specified resources.')
param location string = resourceGroup().location

@description('The base name to be appended to all provisioned resources.')
@maxLength(13)
param resourceBaseName string = uniqueString(resourceGroup().id)

@description('Specifies the IP address for the storage account ACL rules.')
param saACLIP string

resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'pubstorage${resourceBaseName}'
  identity:{
    type: 'SystemAssigned'
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value:saACLIP
        }
      ]
    }
  }
}

resource sablobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: sa
}

resource inputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'input'
  parent: sablobService
}

resource outputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'output'
  parent: sablobService
}
