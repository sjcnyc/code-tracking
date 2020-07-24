$arrylist = New-Object System.Collections.ArrayList

@"
DISCO_US-SBMEVPN
MUC-NMS-APPL-VPN_CLIENT
SYD-HGS VPN-Users
US-SBMEVPN-3RD-PARTIES
SMS-Cisco VPN Client
US-SBMEVPN-Wipro-Aoma
SSLVPN
SYD-HGS VPN-Admins
SMS-CiscoVPN 5 1
SSL-VPN-NC-DEFAULT-PROFILE
EXT-SSLVPNUSR-L Change User Token on Defender Tab
WWI-US-Juniper SSL VPN Users
OSL-OCG All Norway VPN Restrictions
SYD-HGS SSL VPN Users
WWI-US-Juniper SSL VPN Users SonyMusicCentralONLY
WWI-US-Juniper SSL VPN Token Users
WWI-US-Juniper SSL VPN UltraMusic Token Users
US-SBMEVPN-Keane-GRS
LON-KHS VPN INSTALLER
GTL-ADA Juniper SSL Gieman Restricted Access
GTL-ADA Juniper SSL Munich WiPro
HKG-APRO Juniper SSL HK AS400
GTL-ADA Juniper SSL CMG Restricted Access
GTL-ADA Juniper SSL KSF Kiev
GTL-ADA Juniper SSL 105 Music
GTL-ADA Juniper SSL Licensee users
HKG-APRO Juniper SSL India AS400
GTL-ADA Juniper SSL users
GTL-ADA Juniper SSL Italy ExtCon
GTL-ADA Juniper SSL Arvato Dev
GTL-ADA Juniper SSL BMG Rights
GTL-ADA Juniper SSL Hanse Orga
GTL-ADA Juniper SSL Italy ExtCon2
WWI-Juniper-SSL-Latin Users
WWI-Juniper-SSL-North America Users
WWI-Juniper-SSL-Asia Pacific Users
WWI-Juniper-SSL-European Users
HKG-APRO Juniper SSL Users
GTL-ADA Juniper SSL Token Users
GTL-ADA Juniper SSL UK WMW
GTL-ADA Juniper SSL Universum Film
WWI-Juniper-SSL-North America-Pulsar Users
HKG-APRO Juniper SSL DADC Users
GTL-ADA Juniper SSL Coyo
GTL-ADA Juniper SSL Munich Online
WWI-Juniper-SSL-DADC-ACCT-MGT
WWI-Juniper-SSL-DADC-Media-Prod
WWI-Juniper-SSL-OrchardUsers
WWI-Juniper-SSL-CenturyMediaUsers
WWI-Juniper-SSL-CulverCityLot
WWI-Juniper-SSL-BitTitanUsers
"@ -split [environment]::NewLine | ForEach-Object {
   $psObj = [pscustomobject]@{
        'Group' = $_
        'Count' = (Get-QADGroup $_ | Get-QADGroupMember -sizelimit 0).count
    }
    $null = $arrylist.Add($psObj)
}

$arrylist
$arrylist.Count