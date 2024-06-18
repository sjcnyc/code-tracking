
$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
</style>'

Write-Output "Connecting to Azure"
$pscred = $Secret:Graphcreds
Connect-AzAccount -Credential $pscred | Out-Null

$token = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"
Connect-MgGraph -AccessToken ($token.Token | ConvertTo-SecureString -AsPlainText -Force) -NoWelcome | Out-Null

$RootDirectory = "c:\support\TSBlobCopy"
$Date          = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmss")

$SAS       = "https://stmanitest.blob.core.windows.net/dropoff?sp=racwdl&st=2024-06-18T12:57:04Z&se=2024-06-18T20:57:04Z&spr=https&sv=2022-11-02&sr=c&sig=nBNRr8z%2BLemzL1%2F9Rrxtxq%2BS%2FezjbHi47PU4GXRuD%2Bc%3D"
$uri       = [System.Uri] $SAS
$stName    = $uri.DnsSafeHost.Split(".")[0]
$container = $uri.LocalPath.Substring(1)
$sasToken  = $uri.Query -replace "\?", ""

$AzGroups = @{
    "AZ_DG_All_Sony_Music_NON_Employees" = "8afcc0fd-967d-47c3-9dcd-91a8dfff5e5e"
    "AZ_DG_All_Sony_Music_Employees"     = "b21ec49b-925c-444c-8ff4-75f190ba8e41"
}

$AZGroups.GetEnumerator() | ForEach-Object {
    $GroupSplat = @{
        GroupName = $_.key
        ObjectId  = $_.value
    }
    Write-Output "Getting $($GroupSplat.GroupName) Members"
    Get-MgGroupMemberAsUser -GroupId $GroupSplat.ObjectId -Property "displayName, userprincipalName, givenName, surName, mail" -ConsistencyLevel eventual -All |
        Select-Object displayName, userprincipalName, givenName, surName, mail |
        Export-Csv -Path "$($RootDirectory)\$($GroupSplat.GroupName)_Members_$($Date).csv" -NoTypeInformation
}

$stContext = New-AzStorageContext -StorageAccountName $stName -SasToken $sasToken

$csvfiles = @()
Get-ChildItem -Path $RootDirectory -File -Filter *.csv | ForEach-Object {
    $fileToUpload = $_.FullName
    $blobName = $_.Name
    Write-Output "Uploading $blobName to $container"
    Set-AzStorageBlobContent -File $fileToUpload -Container $container -Context $stContext -Force -Blob $blobName | Out-Null
    $csvfiles += $fileToUpload
}

$HTML = New-HTMLHead -title "DWH Databridge SME csv upload" -style $Style1
$HTML += "<h3>Csv files upladed successfully, see attached.</h3>" | Close-HTML

$EmailParams = @{
  to =        "sconnea@sonymusic.com"
  from       = 'PwSh Alerts pwshalerts@sonymusic.com'
  subject    = 'DWH Databridge SME csv upload'
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = ($HTML |Out-String)
  BodyAsHTML = $true
}
Send-MailMessage @EmailParams -Attachments $csvfiles 3>$null

foreach ($file in $csvfiles) {
    Remove-Item $file
}
Write-Output "All Done!"