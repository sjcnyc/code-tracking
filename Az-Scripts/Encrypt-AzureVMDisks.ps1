##encrypt the existing virtual machine using below script
connect-AzAccount
    
$rgName = 'your resource group name'
$location = 'location name'
    
Register-AzResourceProvider -ProviderNamespace 'Microsoft.KeyVault'
Get-AzResourceGroup -Location $location -Name $rgName
    
#create a new keyvault
$keyVaultName = 'your key vault name'
New-AzKeyVault -Location $location `
  -ResourceGroupName $rgName `
  -VaultName $keyVaultName `
  -EnabledForDiskEncryption
    
Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'myKey' -Destination 'Software'
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName;
$diskEncryptionKeyVaultUrl = $keyVault.VaultUri;
$keyVaultResourceId = $keyVault.ResourceId;
$keyEncryptionKeyUrl = (Get-AzKeyVaultKey -VaultName $keyVaultName -Name myKey).Key.kid;
    
    
Set-AzVMDiskEncryptionExtension -ResourceGroupName $rgName `
  -VMName 'your vm name' `
  -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl `
  -DiskEncryptionKeyVaultId $keyVaultResourceId `
  -KeyEncryptionKeyUrl $keyEncryptionKeyUrl `
  -KeyEncryptionKeyVaultId $keyVaultResourceId
    
Get-AzVmDiskEncryptionstatus -ResourceGroupName $rgName -VMName 'your Vm name'