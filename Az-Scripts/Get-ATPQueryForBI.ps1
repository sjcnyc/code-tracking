using namespace System.Collections.Generic

$List = [List[PSObject]]::new()

# ATP vars
$tenantId = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
$clientId = "ca818975-e445-4d22-bbbb-3f239b6bbb85"
$clientSecret = ".UaG4TxY~arWnA-T.2Zwfew~M23.7n-~hb"
$resource = "https://api.securitycenter.windows.com"

$requestAccessTokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=$resource"

$token = Invoke-RestMethod -Method Post -Uri $requestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

Write-Host $token.access_token

$ATPApiUri = "https://api.securitycenter.windows.com/api/machines"
#$ATPApiUri = "https://api.securitycenter.windows.com/api/users"
#/api/machines/1e5bc9d7e413ddd7902c2932e418702b84d0cc07/logonusers

$headers = @{}

$headers.Add("Authorization", "$($token.token_type) " + " " + "$($token.access_token)")

$ATPResults = Invoke-RestMethod -Method Get -Uri $ATPApiUri -Headers $headers

# d682ebe51583f5ac0d15aa292f85ff979f1b572f
$Logonusers = "https://api.securitycenter.windows.com/api/machines/d682ebe51583f5ac0d15aa292f85ff979f1b572f/logonusers"

foreach ($atpresult in $ATPResults.value) {
  $Logonusers = "https://api.securitycenter.windows.com/api/machines/$($atpresult.Id)/logonusers"
  $User = Invoke-RestMethod -Method Get -Uri $Logonusers -Headers $headers

  $PSobj = [pscustomobject]@{
    userid                 = $User.id
    useraccountName        = $User.accountName
    useraccountDomain      = $User.accountDomain
    useraccountSid         = $User.accountSid
    userfirstSeen          = $User.firstSeen
    userlastSeen           = $User.lastSeen
    userlogonTypes         = $User.logonTypes
    userlogOnMachinesCount = $User.logOnMachinesCount
    userisDomainAdmin      = $User.isDomainAdmin
    userisOnlyNetworkUser  = $User.isOnlyNetworkUser
    id                     = $atpresult.id
    computerDnsName        = $atpresult.computerDnsName
    firstseen              = $atpresult.firstseen
    lastseen               = $atpresult.lastseen
    osplatform             = $atpresult.osplatform
    osversion              = $atpresult.osversion
    osProcessor            = $atpresult.osProcessor
    version                = $atpresult.version
    lastipaddress          = $atpresult.lastipaddress
    lastexternalipaddress  = $atpresult.lastexternalipaddress
    agentVersion           = $atpresult.agentVersion
    osbuild                = $atpresult.osbuild
    healthStatus           = $atpresult.healthStatus
    device_value           = $atpresult.device_value
    rbacGroupId            = $atpresult.rbacGroupId
    rbac_group_name        = $atpresult.rbac_group_name
    riskScore              = $atpresult.riskScore
    exposureLevel          = $atpresult.exposureLevel
    isAadJoined            = $atpresult.isAadJoined
    aadDeviceId            = $atpresult.aadDeviceId
  }
  [void]$list.Add($psobj)
}

# Azure storage vars
#$strgAccountName = "epaatpdefenderfundev"
#$strgAccountKey = "LZdFCQVKKZfoTt7Rjkv715itU8YTNKbkVMzi422ujmZVcMZSyAlQQvJ59FmDhX1FW9t7ZZp8mjNHUOhZcfJqOw=="
#$strgContainer = "atp-defender"
#$blobName = "ATPDefender_test_sean.csv"

#$selectObjectSplat = @{
#  Property = 'id', 'computerDnsName', 'firstSeen', 'lastSeen', 'osPlatform', 'osVersion', 'osProcessor', 'version', 'lastIpAddress', 'lastExternalIpAddress', 'agentVersion', 'osBuild', 'healthStatus', 'deviceValue', #'rbacGroupId', 'rbacGroupName', 'riskScore', 'exposureLevel', 'isAadJoined', 'aadDeviceId'
#}

#$ATPResults.value | Select-Object @selectObjectSplat | Export-Csv "D:\Temp\$($blobName)" -Force
#$fileName = Get-ChildItem -Path "D:\Temp\$($blobName)"

#$ctx = New-AzStorageContext -StorageAccountName $strgAccountName -StorageAccountKey $strgAccountKey
#Set-AzStorageBlobContent -Container $strgContainer -Context $ctx -File $filename -Blob $blobName -Force
#Remove-Item "D:\Temp\$($blobName)"
#hope this commits lol

$list