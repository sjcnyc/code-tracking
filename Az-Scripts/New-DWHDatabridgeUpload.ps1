$connectMgGraphSplat = @{
    NoWelcome             = $true
    ClientId              = '91152ce4-ea23-4c83-852e-05e564545fb9'
    TenantId              = 'f0aff3b7-91a5-4aae-af71-c63e1dda2049'
    CertificateThumbprint = 'c838457e980e940c42d9950fa3b3bd8f05b6e919'
}

Connect-MgGraph @connectMgGraphSplat

$RootDirectory = "C:\Support\TSBlobCopy"
#$Date          = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmss")

#Testing on sme tenant
#$SAS       = "https://stmanitest.blob.core.windows.net/dropoff?sp=racwdl&st=2024-07-29T15:20:06Z&se=2025-07-29T23:20:06Z&spr=https&sv=2022-11-02&sr=c&sig=MA9kRy5%2FmACoM8MHxgJ1qtRJPoygiMRtmPEtb79rpaI%3D"
$SAS       = "https://euspreportingsa.blob.core.windows.net/databridge-receive-sme?sp=acw&st=2024-07-08T17:20:59Z&se=2024-08-11T14:20:59Z&spr=https&sv=2022-11-02&sr=c&sig=kQzdRfPdd7dAhR89oa9zIUqDIF3uYouXL%2FJgydJMyL0%3D"
$uri       = [System.Uri] $SAS
$stName    = $uri.DnsSafeHost.Split(".")[0]
$container = $uri.LocalPath.Substring(1)
$sasToken  = $uri.Query -replace "\?", ""

$AzGroups = @{
    "AZ_DG_All_Sony_Music_NON_Employees" = "8afcc0fd-967d-47c3-9dcd-91a8dfff5e5e"
    "AZ_DG_All_Sony_Music_Employees"     = "b21ec49b-925c-444c-8ff4-75f190ba8e41"
    "AZ_DG_All_SCA_Staff"                = "fdcbed78-0eec-42b0-86a8-209606e53f51"
    "AZ_DG_All_SMP_Staff"                = "2c6c09a8-37ff-4ccc-bff9-e6ebc6ad4899"
    "AZ_DG_All_SIE_Staff_US"             = "3ba76571-c77a-4621-8d04-45f0879d09ff"
    "AZ_DG_All_SPE_Staff"                = "3c432edd-d404-4c66-a7b6-7b2621dc2f18"
}

$AZGroups.GetEnumerator() | ForEach-Object {
    $GroupSplat = @{
        GroupName = $_.key
        ObjectId  = $_.value
    }
    Write-Output "Getting $($GroupSplat.GroupName) Members"
    Get-MgGroupMemberAsUser -GroupId $GroupSplat.ObjectId -Property "displayName, userprincipalName, givenName, surName, mail, id" -ConsistencyLevel eventual -All |
        Select-Object displayName, userprincipalName, givenName, surName, mail, id,  @{N='GroupName'; E={$GroupSplat.GroupName}} |
        Export-Csv -Path "$($RootDirectory)\$($GroupSplat.GroupName)_Members.csv" -NoTypeInformation
}

$stContext = New-AzStorageContext -StorageAccountName $stName -SasToken $sasToken

$csvfiles = @()
$csvNames = @()
Get-ChildItem -Path $RootDirectory -File -Filter *.csv | ForEach-Object {
    $fileToUpload = $_.FullName
    $blobName = $_.Name
    Write-Output "Uploading $blobName to $container"
    Set-AzStorageBlobContent -File $fileToUpload -Container $container -Context $stContext -Force -Blob $blobName | Out-Null
    $csvfiles += $fileToUpload
    $csvNames += $blobName
}

$Body = @"
$($AzGroups.Count) files uploaded successfully <br>
<br>
See attached csv reports.
"@

$EmailSplat = @{
    #To               = "Sean.Connealy@sonymusic.com"
    To               = "Alex.Moldoveanu@sonymusic.com", "Sean.Connealy@sonymusic.com"
    From             = 'PwSh Alerts <pwshalerts@sonymusic.com>'
    Subject          = "DWH Databridge upload"
    Heading          = "DWH Databridge upload"
    HeadingAlignment = "Center"
    Body             = "$Body"
    BodyAlignment    = "Center"
    SmtpServer       = "cmailsony.servicemail24.de"
    footer           = "Runbook completed: $(Get-Date -Format G)"
    ColorScheme      = @{
        BodyTextColor      = "#ffffff"
        BackgroundColor    = "#f6f6f6"
        ContainerColor     = "#008cc9"
        containerTextColor = "#ffffff"
        HeadingTextColor   = "#ffffff"
        FooterTextColor    = "#999999"
        LinkColor          = "#999999"
        ButtonColor        = "#3498db"
        ButtonTextColor    = "#ffffff"
    }
}

Send-HtmlMailMessage @EmailSplat -Attachments $csvfiles 3>$nul

foreach ($file in $csvfiles) {
    Start-Sleep 1
    Remove-Item $file
}
Write-Output "All Done!"