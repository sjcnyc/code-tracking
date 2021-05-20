import-module ActiveDirectory

$Computers = Import-Csv -Path "C:\temp\USAInactiveComputerObjects.csv"

foreach ($Computer in $Computers) {
  $getADObjectSplat = @{
      SearchBase = $computer.DistinguishedName
      Properties = 'whenCreated', 'msFVE-RecoveryPassword', 'Name', 'DistinguishedName', 'msFVE-RecoveryGuid'
      Filter = 'objectClass -eq "msFVE-RecoveryInformation"'
  }
  Get-ADObject @getADObjectSplat | Select-Object Name, DistinguishedName, whenCreated, msFVE-RecoveryPassword, msFVE-RecoveryGuid #|
  #Export-Csv -Path "c:\temp\Bitlocker-backup.csv" -NoTypeInformation -Append
}

Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase "CN=ULL507B9D48A997,OU=Win7,OU=Workstations,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com" -Properties whenCreated, msFVE-RecoveryPassword, Name, DistinguishedName -Server 'me.sonymusic.com' | Select-Object Name, DistinguishedName, whenCreated, msFVE-RecoveryPassword

$objComputer = Get-ADComputer "ULL507B9D48A997"
$Bitlocker_Object = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $objComputer.DistinguishedName -Properties 'msFVE-RecoveryPassword'
$Bitlocker_Object

foreach ($Computer in $Computers) {

  Get-QADObject -LdapFilter '(objectcategory=msFVE-RecoveryInformation)' -SearchRoot $Computer.DistinguishedName -IncludedProperties WhenCreated, msFVE-RecoveryGuid, msFVE-RecoveryPassword | Select-Object @{N = "Name"; E = { $Computer.Name } }, whenCreated, msFVE-RecoveryGuid, msFVE-RecoveryPassword
}