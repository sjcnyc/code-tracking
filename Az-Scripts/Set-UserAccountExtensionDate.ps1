using namespace System.Collections.Generic
$userList = [List[PSObject]]::new()

$connectGraphSplat = @{
  ClientId              = "91152ce4-ea23-4c83-852e-05e564545fb9"
  Tenant              = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
  CertificateThumbprint = "7A7B75A0FF030BBC6CACCF3928C3079B72FCB2A8"
}
Connect-Graph @connectGraphSplat

$userList = [List[PSObject]]::new()

$getMessageSplat = @{
  UserId = '1dcf9218-b0ae-450f-9cba-c8446edf8cc2'
  Filter = "contains(subject,'Extend')"
}

$users = Get-MgUserMessage @getMessageSplat | Select-Object -ExpandProperty bodycontent

$regEx = 'username:\s+(.*)[\s\S]+?' + 'extensiondate:\s+(.*)[\s\S]+?'

foreach ($user in $users) {

  $user | Out-String |
  Where-Object { $_ -match $regEx } |
  ForEach-Object {
    $PSObj = [pscustomobject]@{
      UserName   = $matches[1]
      ExtendDate = $matches[2]
    }
    [void]$userList.Add($PSObj)
  }
}

$userList | Select-Object username


# ? Get-ADUser -filter "employeeNumber -eq ""$Currentid""" dsdsd