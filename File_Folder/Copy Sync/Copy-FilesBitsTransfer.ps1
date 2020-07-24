function Copy-Files
{
  param(
    [string]$Source,
    [string]$Destination
    )

    $Folders = Get-ChildItem -Name -Path $Source -Directory -Recurse
    
    Import-Module BitsTransfer

    #Start Bits Transfer for all items in each directory. Create Each directory if they do not exist at destination.
    Start-BitsTransfer -Source $Source\*.* -Destination $Destination
    foreach ($i in $folders)
    {
        $exists = Test-Path $Destination\$i
        if ($exists -eq $false) {New-Item $Destination\$i -ItemType Directory}
        Start-BitsTransfer -Source $Source\$i\*.* -Destination $Destination\$i
    }
}


function Email
{
    #Email Config
    $smtpServer = 'smtp01.bmg.bagint.com'
    $from = 'Posh Alerts poshalerts@sonymusic.com'
    $emailaddress = 'sconnea@sonymusic.com'

    #Email subject
    $subject = 'Copy os S:\ Copy Complete'

    #Email body
    $body = '<p>Copy os S:\ Copy Complete</p>'
    
    #Send email message
    Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High
}

