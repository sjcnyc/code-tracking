@description('The name of the AVD distribution')
param distName string

@description('Location for all resources')
param location string = 'eastus'

@description('Created by tag value')
param createdBy string

@description('Created on date tag value')
param createdOn string = utcNow('MM/dd/yyyy')

@description('Object ID of the AVD contributor group')
param contribGroupId string

// Variables
var resourceGroupName = 'RG-${distName}-P-EUS'
var storageAccountName = 'stsme${distName}${uniqueString(resourceGroup().id)}'
var shareName = '${toLower(distName)}-userprofiles'
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb') // Storage File Data SMB Share Contributor

// Resource Group is created in PowerShell script as Bicep doesn't support RG creation

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
  properties: {
    allowBlobPublicAccess: false
    largeFileSharesState: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    fileServices: {
      properties: {
        protocolSettings: {
          smb: {
            multichannel: {
              enabled: true
            }
          }
        }
      }
    }
  }
  tags: {
    CreatedBy: createdBy
    CreatedOn: createdOn
  }
}

// File Share
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccount.name}/default/${shareName}'
  properties: {
    shareQuota: 100
    enabledProtocols: 'SMB'
  }
}

// Role Assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, contribGroupId, roleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: contribGroupId
    principalType: 'Group'
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output shareName string = shareName
output resourceGroupName string = resourceGroupName
