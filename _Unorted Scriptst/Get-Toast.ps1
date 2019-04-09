$Networks = Get-WmiObject win32_networkadapterconfiguration -filter "IPEnabled='True'" |
    Select-Object DNSHostname, MACAddress, IPAddress, Description | Where-Object {$_.Description -notlike "*Virtual*"}

$hostname = $($Networks.DNSHostname)
$ipaddress = $($Networks.IPAddress)
$macaddress = $($Networks.MACAddress)

$data =
@"
Host Name:   $hostname
IP Address:  $ipaddress
Mac Address: $macaddress
"@

$text0 = New-BTText -Content "IP Addresser v4"
$text1 = New-BTText -Content "Host Name:     $hostname"
$text2 = New-BTText -Content "IPAddress:       $ipaddress     MacAddress:    $macaddress"

$clip = Set-Clipboard -Value $data

$image = New-BTImage -Source 'C:\temp\lan.png' -AppLogoOverride -Crop Default

$binding1 = New-BTBinding -Children $text0, $text1, $text2 -AppLogoOverride $image

$visual1 = New-BTVisual -BindingGeneric $binding1

$header = New-BTHeader -id "primary Header" -Title "IP Addresser v4"
$button1 = New-BTButton -Content "Copy" -Arguments $image -ActivationType Protocol
$action1 = New-BTAction -Buttons (New-BTButton -Content 'Copy' -Arguments "(Set-Clipboard -Value $data)" )

$content1 = New-BTContent -Visual $visual1 -Actions $action1 -Duration Long
$guid = New-Guid
Submit-BTNotification -Content $content1 -UniqueIdentifier $guid.Guid