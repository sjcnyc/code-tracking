Import-Module Az

$ConnectionString = "DefaultEndpointsProtocol=https;AccountName=sa01sftx3406815508;AccountKey=hTcPz4b69+50NXAxlE/P/bOFeD7uqVy3rISDkBcmzD7eVL228oCho4xf96g6zJcGqxdlCM1gSXAY+AStckodmg==;EndpointSuffix=core.windows.net"
$Context = New-AzStorageContext -ConnectionString $ConnectionString
$SrcContainer = "con01-sf-archive"

#Get reference for container
$Container = Get-AzStorageContainer -Name $SrcContainer -Context $context
#Get reference to blobs
$Blobs = Get-AzStorageBlob -Container $SrcContainer -Context $context

#Loop through blobs
foreach ($Blob in $Blobs) {
    # Get reference for file
    $Client = $Container.CloudBlobContainer.GetBlockBlobReference($Blob.Name)
    # CloudBlockBlob.DownloadText Method
    # https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.storage.blob.cloudblockblob.downloadtext?view=azure-dotnet
    $File = $Client.DownloadText()

    $TicketXML = [Xml]$File

    try {

        $UserId = $TicketXML.userAction.userId

        $getADUserSplat = @{
            Identity = $UserId
            Properties = 'DistinguishedName', 'sAMAccountName', 'accountExpires', 'Name'
        }

        $ADUser = Get-ADUser @getADUserSplat | Select-Object DistinguishedName, sAMAccountName, Name, @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }

        Write-Output $ADUser

    } catch {

        Write-Output "$($Error[0].Exception.Message)"

        if ($null -eq $ADUser.samaccountname) {
            $UserId = "N/A"
        }

        $Body = @"
<pre>
UserId:   $($UserId)
Ticket#:  $($TicketXML.userAction.ticketnumber)
Error:    $($Error[0].Exception.Message)
</pre>
"@

        $Body2 = @"
<pre>
UserId:   $($UserId)
Ticket#:  $($TicketXML.userAction.ticketnumber)
RefId:    $($TicketXML.userAction.RefId)
Error:    $($Error[0].Exception.Message)
</pre>
"@
        $EmailParams = @{
          to         = "sconnea@sonymusic.com", "Salesforce.Requests@sonymusic.com"
          from       = 'PwSh Alerts pwshalerts@sonymusic.com'
          subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
          smtpserver = 'cmailsony.servicemail24.de'
          body       = ($Body | Out-String)
          bodyashtml = $true
        }

        Send-MailMessage @EmailParams 3>$null

        $EmailParams2 = @{
          to         = "sconnea@sonymusic.com", "salesforce.requests@4-umsi1z03v0oznmvjd6i9do7wep3916t0e9wojknoc39w61pd0.7-jlcaeao.na33.case.salesforce.com"
          from       = 'PwSh Alerts pwshalerts@sonymusic.com'
          subject    = "Account access not extended. Ticket# $($TicketXML.userAction.ticketnumber)"
          smtpserver = 'cmailsony.servicemail24.de'
          body       = ($Body2 | Out-String)
          bodyashtml = $true
        }

        Send-MailMessage @EmailParams2 3>$null
        Write-Output "Sending error email, user: $($UserId)"
        $ADUser = $null
    }

    if ($ADUser) {

        $ExpiresDate = [datetime]::parseexact((($TicketXML.userAction).expdate), 'yyyy-MM-dd HH:mm:ss', $null).ToString('MM/dd/yyyy HH:mm:ss tt')

        Set-ADAccountExpiration -Identity $($ADUser.DistinguishedName) -DateTime $ExpiresDate -Credential $pscred # NEW CHANGE

        $NewAccountexpires = Get-ADUser -Identity $UserId -Properties accountExpires, Name |
        Select-Object @{N = "ExpiryDate"; E = { [datetime]::FromFileTime($_.accountExpires) } }
        Write-Output "Updating expiry date for: $($UserId) - $($NewAccountexpires)"

        $Body = @"
<pre>
UserId:      $($UserId)
Ticket#:     $($TicketXML.userAction.ticketnumber)
RefId:       $($TicketXML.userAction.RefId)
ExpiresDate: $(($NewAccountexpires.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt')) 
</pre>
"@
        $EmailParams3 = @{
          to         = "sconnea@sonymusic.com", "extend.account@sonymusic.com", "salesforce.requests@4-umsi1z03v0oznmvjd6i9do7wep3916t0e9wojknoc39w61pd0.7-jlcaeao.na33.case.salesforce.com"
          from       = 'PwSh Alerts pwshalerts@sonymusic.com'
          subject    = "Account access extended. Ref# $($TicketXML.userAction.RefId)"
          smtpserver = 'cmailsony.servicemail24.de'
          body       = ($Body | Out-String)
          bodyashtml = $true
        }

        Send-MailMessage @EmailParams3 3>$null
        Write-Output "Sending success email, user: $($UserId)"

        $UserObject = [pscustomobject]@{
          Name              = $ADUser.Name
          SamAccountName    = $ADUser.sAMAccountName
          DistinguishedName = $ADUser.DistinguishedName
          AccountExpires    = ($ADUser.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt') 
          NewAccountExpires = ($NewAccountexpires.ExpiryDate).ToString('MM/dd/yyyy HH:mm:ss tt') 
          Scriptexecution   = (Get-Date).ToString('MM/dd/yyyy HH:mm:ss tt')
        }

        $UserObject | Export-CSV "$($LogPath)\$($LogName)" -NoType -Append
        "Updating Log: $($LogPath)\$($LogName)"

        $ADUser = $null
      }
}

#Set-AzStorageBlobContent -Blob  -BlobType Append -File "" append blob



<#
#Get Storage Account context
$context = New-AzStorageContext -StorageAccountName "<storage-account>" -SasToken "<sas-token>" # or -StorageAccountKey, you can use your preferred method for authentication
#Get reference for container
$container = Get-AzStorageContainer -Name "<container-name>" -Context $context
#Get reference for file
$client = $container.CloudBlobContainer.GetBlockBlobReference("<file-name>")
#Read file contents into memory
$file = $client.DownloadText()
#>