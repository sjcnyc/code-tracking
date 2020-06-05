$connectGraphSplat = @{
  ClientId              = "91152ce4-ea23-4c83-852e-05e564545fb9"
  TenantId              = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
  CertificateThumbprint = "7A7B75A0FF030BBC6CACCF3928C3079B72FCB2A8"
}
Connect-Graph @connectGraphSplat

$getMessageSplat = @{
  UserId = '1dcf9218-b0ae-450f-9cba-c8446edf8cc2'
  Filter = "contains(subject,'Extend')"
}

$users = Get-MgUserMessage @getMessageSplat | Select-Object bodycontent, ID

$regEx = 'username:\s+(.*)[\s\S]+?' + 'extensiondate:\s+(.*)[\s\S]+?'

foreach ($user in $users) {

  $objArr = @()
  $objArr = ($user | Out-String) |
  Where-Object { $_ -match $regEx } |
  ForEach-Object {
    [pscustomobject] ([ordered]@{
        UserName   = $matches[1]
        ExtendDate = $matches[2]
      })
  }
  $objArr
}
