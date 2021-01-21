# ATP vars
$tenantId = "f0aff3b7-91a5-4aae-af71-c63e1dda2049"
$clientId = "ca818975-e445-4d22-bbbb-3f239b6bbb85"
$clientSecret = "65IqCi0o?7.aALcaipvltYOdxyVVap[?"
$resource = "https://api.securitycenter.windows.com"

$requestAccessTokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=$resource"

$token = Invoke-RestMethod -Method Post -Uri $requestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'

$ATPApiUri = "https://api.securitycenter.windows.com/api/machines"

$headers = @{}

$headers.Add("Authorization", "$($token.token_type) " + " " + "$($token.access_token)")

$ATPResults = Invoke-RestMethod -Method Get -Uri $ATPApiUri -Headers $headers

# Azure storage vars
$strgAccountName = "epaatpdefenderfundev"
$strgAccountKey = "LZdFCQVKKZfoTt7Rjkv715itU8YTNKbkVMzi422ujmZVcMZSyAlQQvJ59FmDhX1FW9t7ZZp8mjNHUOhZcfJqOw=="
$strgContainer = "atp-defender"
$blobName = "ATPDefender_test_sean.csv"

$selectObjectSplat = @{
  Property = 'id', 'computerDnsName', 'firstSeen', 'lastSeen', 'osPlatform', 'osVersion', 'osProcessor', 'version', 'lastIpAddress', 'lastExternalIpAddress', 'agentVersion', 'osBuild', 'healthStatus', 'deviceValue', 'rbacGroupId', 'rbacGroupName', 'riskScore', 'exposureLevel', 'isAadJoined', 'aadDeviceId'
}

$ATPResults.value | Select-Object @selectObjectSplat | Export-Csv "D:\Temp\$($blobName)" -Force
$fileName = Get-ChildItem -Path "D:\Temp\$($blobName)"

$ctx = New-AzStorageContext -StorageAccountName $strgAccountName -StorageAccountKey $strgAccountKey
Set-AzStorageBlobContent -Container $strgContainer -Context $ctx -File $filename -Blob $blobName -Force
Remove-Item "D:\Temp\$($blobName)"
#hope this commits lol