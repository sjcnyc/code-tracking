$password = ConvertTo-SecureString "KeepItCleanKids!" -AsPlainText -Force

$Creds = New-Object System.Management.Automation.PSCredential ('repoman@SonyMusicEntertainment.onmicrosoft.com', $password)

Connect-EWSService -Mailbox 'repoman@SonyMusicEntertainment.onmicrosoft.com' -Credential $Creds -ServiceUrl 'https://outlook.office365.com/EWS/Exchange.asmx'

$emaiItems = Get-EWSFolder Inbox | Get-EWSItem -Limit 20000 -Filter kind:email -PropertySet FirstClassProperties |
    Select-Object *

foreach ($item in $emaiItems) {

    $pscustomObj = [pscustomobject]@{
        'From'                              = $item.From
        'ReplyTo'                           = $item.ReplyTo
        'Sender'                            = $item.Sender
        'Subject'                           = $item.Subject
        'Received'                          = $item.ReceivedBy
        'Message-ID'                        = $item.InternetMessageId
        'Authentication-Results'            = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Authentication-Results'}).value
        'Received-SPF'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received-SPF'}).value
        'Return-Path'                       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Return-Path'}).value
        'DKIM-Signature'                    = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'DKIM-Signature'}).value
        'X-Originating-ip'                  = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Originating-IP'}).value
        'X-Forefront-Antispam-Report'       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Forefront-Antispam-Report'}).value
        'X-MS-Exchange-Organization-AuthAs' = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-MS-Exchange-Organization-AuthAs'}).value
        'X-CustomSpam'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-CustomSpam'}).value
        'X-Received'                        =(($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received'}).value | Out-String).Trim()
        #'X-Headers'                         = ($item.InternetMessageHeaders | ForEach-Object {"$($_.Name): $($_.Value)"} | Out-String).Trim()
    }

    $pscustomObj | Export-Csv \\storage\pstholding$\SpamLogs\X-Headers-$((get-date).ToString("yyy-MM-dd")).csv -NoTypeInformation -Append

}