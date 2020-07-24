<#
 @"
 sconnea
 "@ -split [environment]::NewLine | ForEach-Object {

  $proxyUpper = Get-aduser $_ -Server 'me.sonymusic.com' -pr proxyaddresses | Select-Object -ExpandProperty proxyaddresses | Where-Object {$_ -cmatch '^SMTP'}
  Set-ADUser -identity $_ -Replace @{'ProxyAddresses' = @($_.proxyaddresses -Replace $proxyUpper, $proxyUpper.ToLower())} -WhatIf
 }

 ((Get-QADUser -Service 'me.sonymusic.com' sconnea -IncludeAllProperties).ProxyAddresses).Where{$_ -like "SMTP*" -and $_ -cmatch "[A-Z]"}
 (Get-QADUser -Service 'nycmnetads001.mnet.biz:389' atorre1 -IncludeAllProperties).PrimarySMTPAddress

 Import-Csv proxy.csv | ForEach-Object {
    Get-ADUser $_.Name | Set-ADUser -Add @{proxyAddresses = ($_.proxy -split ";")}
 }
 get-aduser sconnea -properties * | select-object name, samaccountname, surname, enabled, @{"name"="proxyaddresses";"expression"={$_.proxyaddresses}}

 Get-aduser sconnea -Server 'me.sonymusic.com' -pr proxyaddresses | Select-Object -ExpandProperty proxyaddresses | Where-Object {$_ -cmatch '^SMTP'}
 get-aduser sconnea -properties * | select-object name, samaccountname, surname, enabled, @{N = "proxyaddresses"; E = {$_.proxyaddresses}}

 #| Select-Object @{n='Name';e={$UPN}} -ExpandProperty ServiceStatus | Format-Table ServicePlan, ProvisioningStatus -GroupBy Name

Get-aduser sconnea @Params | Select-Object $Params.Properties, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses}}

Select-Object Name, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ";"}}
#>

Get-Aduser -p proxyaddresses -Filter *| Select-Object -ExpandProperty proxyAddresses -First 1000 | Where-Object {$_ -cmatch '^SMTP'}

$PSArrayList = New-Object System.Collections.ArrayList

$Params = @{
  Server     = 'me.sonymusic.com'
  Properties = 'SamAccountName',
               'DisplayName',
               'mail',
               'UserPrincipalName',
               'CanonicalName',
               'Description',
               'ProxyAddresses'
}

$users = Get-aduser @Params -filter * | Select-Object $Params.Properties

foreach ($user in $users) {
  $PSobj = [pscustomobject]@{
    SamAccountname    = $user.SamAccountName
    DisplayName       = $user.DisplayName
    mail              = $user.mail
    UserPrincipalName = $user.UserPrincipalName
    CanonicalName     = $user.CanonicalName
    Description       = $user.Description
    ProxyAddresses    = ($user | Select-Object -ExpandProperty proxyaddresses | Out-String).Trim()

  }
  [void]$PSArrayList.Add($PSobj)
}

$PSArrayList | Export-Csv C:\temp\ME_AD_DUMP_WITH_PROXY2.csv -NoTypeInformation

#(Get-aduser sconnea @Params | Select-Object $Params.Properties -ExpandProperty proxyaddresses | out-string).Trim()
