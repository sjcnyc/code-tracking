$LocalXMLPath = "D:\ExtNetAcctLogs\Temp"

$LocalXMLFile = Get-ChildItem -Path $LocalXMLPath

foreach ($XMLFile in $LocalXMLFile) {

  $TicketXML = [Xml] (Get-Content -Path "$($XMLFile.FullName)")

  $UserId = $TicketXML.userAction.userId

  $ADUser = Get-ADUser -Identity $UserId -Properties DistinguishedName, sAMAccountName, accountExpires, Name | 
  Select-Object DistinguishedName, sAMAccountName, Name, @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }
  Write-Output "Getting properties for: $($ADUser.samaccountname)"

  if ($ADUser) {
        
    $ExpiresDate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy HH:mm:ss tt')

    Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate 

  }
}