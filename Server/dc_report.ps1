# XPath compound filter
$filter=@"
    *[System[(EventID=4624)]] and 
    *[EventData[Data[@Name='TargetUserName'] and (Data='sconnea')]]
"@

$dcs = 'nycsbmeads0011'
 
Foreach($DC in $dcs){
    $events+=Get-WinEvent -LogName security -FilterXPath $filter -ComputerName $dc
}

$events | 
    ForEach-Object{
        $event=[xml]($_.ToXml())
        $data=@{
            User='sconnea'
            Date=$_.TimeCreated
            LogonType=($event.Event.EventData.Data|Where-Object{$_.Name -eq 'LogonType'}).'#text'
            IP=($event.Event.EventData.Data|Where-Object{$_.Name -eq 'IpAddress'}).'#text'
            Controller=$_.MachineName
        }
        New-Object PsCustomObject -Property $data
    } #| Format-Table # OR Export-Csv