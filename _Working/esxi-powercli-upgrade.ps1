###### Connect To VCenter ######
Connect-VIServer -Server "<vcenter server>"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -ParticipateInCEIP: $false

###### Import Stores From CSV ######
Import-Csv "<path to csv file with vmhosts>" | ForEach-Object {
  $VHost = $_.VHost

  #####Backup Host Config######
  Get-VMHostFirmware -VMHost $VHost -BackupConfiguration -DestinationPath "<Path to where you want to store config backup>"

  ###### Get Datastore from VMHost where name is like Store ######
  $DS = Get-VMHost -Name $VHost | Get-Datastore -Name "<the pattern of your datastore name>"

  ###### Get the datastore vmware / linux path ######
  $Path = $DS.ExtensionData.info.url 

  ###### Create a Powershell drive to the Datastore to upload Needed Patch Files ######

  New-PSDrive -Location $ds -Name ds -PSProvider VimDatastore -Root “”

  ###### Create a directory on Datastore ######
  Set-Location ds:
  New-Item -ItemType Directory -Force -Path ds:<folder you want to house the patch on the datastore> 
  # i.e. ds:\patches\6.7PUpgrade

  ###### Copy The update file(s) needed to the new folder ######

  Copy-DatastoreItem -Item "<path where patch folder is locally>\*" -Destination "<folder you want to house the patch on the datastore>" -Recurse

  ###### Remove Powershell Drive ######
  #Set-Location c:
  Remove-PSDrive $ds

  ##### Power down vms that reside on the host######
  Get-VMHost -Name $VHost | Get-VM | shutdown-vmguest -Confirm:$false

  ###### Assign The Patch Variable which is the path plus the name of the Patch File ######
  $Patch = $Path.Substring(5, $Path.Length - 5) + "<path to ds patch folder>/metadata.zip"


  ###### Iniate the Patching Process ######

  Set-VMHost -VMHost $Vhost -State Maintenance
  Install-VMHostPatch -VMHost $VHost -HostPath $Patch
  Set-VMHost -VMhost $Vhost -State Connected
  Restart-VMHost -VMHost $VHost -Force -Confirm:$false

}