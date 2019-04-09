<#
    .SYNOPSIS
    Connect-Office365Services

    PowerShell script defining functions to connect to Office 365 online services 
    or Exchange On-Premises. Call manually or alternatively embed or call from $profile
    (Shell or ISE) to make functions available in your session. If loaded from 
    PowerShell_ISE, menu items are defined for the functions. To surpress creation of 
    menu items, hold 'Shift' while Powershell ISE loads.
       
    Michel de Rooij
    michel@eightwone.com
    http://eightwone.com

    THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
    RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

    Version 1.5, April 6th, 2017

    .LINK
    http://eightwone.com

    Revision History
    ---------------------------------------------------------------------
    1.2	    Community release
    1.3     Updated required version of Online Sign-In Assistant
    1.4	    Added (in-code) AzureEnvironment (Connect-AzureAD)
            Added version reporting for modules
    1.5     Added support for Exchange Online PowerShell module w/MFA
            Added IE proxy config support
            Small cosmetic changes in output

    .DESCRIPTION 
    The functions are listed below. Note that functions may call eachother, for example to 
    connect to Exchange Online the Office 365 Credentials the user is prompted to enter these credentials. 
    Also, the credentials are persistent in the current session, there is no need to re-enter credentials 
    when connecting to Exchange Online Protection for example. Should different credentials be required, 
    call Get-Office365Credentials or Get-OnPremisesCredentials again.

    - Connect-AzureAD            		Connects to Azure Active Directory
    - Connect-AzureRMS           		Connects to Azure Rights Management
    - Connect-ExchangeOnline     		Connects to Exchange Online
    - Connect-SkypeOnline        		Connects to Skype for Business Online
    - Connect-EOP                		Connects to Exchange Online Protection
    - Connect-ComplianceCenter   		Connects to Compliance Center
    - Connect-SharePointOnline   		Connects to SharePoint Online
    - Get-Office365Credentials    		Gets Office 365 credentials
    - Connect-ExchangeOnPremises 		Connects to Exchange On-Premises
    - Get-OnPremisesCredentials    		Gets On-Premises credentials
    - Get-ExchangeOnPremisesFQDNGets 		FQDN for Exchange On-Premises
    - Get-Office365Tenant           		Gets Office 365 tenant name

    .EXAMPLES
    .\Microsoft.PowerShell_profile.ps1
    Defines functions in current shell or ISE session (when $profile contains functions or is replaced with script).
#>

#Requires -Version 3.0

Write-Host "Loading Connect-Office365Services .."

$local:Functions = @( 
    'Connect|Exchange Online|Connect-ExchangeOnline', 
    'Connect|Exchange Online Protection|Connect-EOP', 
    'Connect|Exchange Compliance Center|Connect-ComplianceCenter', 
    'Connect|Azure AD|Connect-AzureAD|MSOnline|Azure Active Directory|http://go.microsoft.com/fwlink/p/?linkid=236297', 
    'Connect|Azure RMS|Connect-AzureRMS|AADRM|Azure RMS|https://www.microsoft.com/en-us/download/details.aspx?id=30339', 
    'Connect|Skype for Business Online|Connect-SkypeOnline|LyncOnlineConnector|Skype for Business Online|https://www.microsoft.com/en-us/download/details.aspx?id=39366', 
    'Connect|SharePoint Online|Connect-SharePointOnline|Microsoft.Online.Sharepoint.PowerShell|SharePoint Online|https://www.microsoft.com/en-us/download/details.aspx?id=35588', 
    'Settings|Office 365 Credentials|Get-Office365Credentials', 
    'Connect|Exchange On-Premises|Connect-ExchangeOnPremises', 
    'Settings|On-Premises Credentials|Get-OnPremisesCredentials', 
    'Settings|Exchange On-Premises FQDN|Get-ExchangeOnPremisesFQDN'
)

$local:CreateISEMenu = ($psISE) -and ([System.Windows.Input.Keyboard]::IsKeyDown('Shift') -eq $false)
If( $local:CreateISEMenu) {Write-Host 'ISE detected, adding ISE menu options'}

# Local Exchange session options
$global:SessionExchangeOptions = New-PSSessionOption -SkipCNCheck -ProxyAccessType IEConfig

function global:Connect-ExchangeOnline {
    If( !($global:Office365Credentials)) { Get-Office365Credentials }
    If( !(Get-Module -Name 'Microsoft.Exchange.Management.ExoPowershellModule' )) {
        Write-Host "Connecting to Exchange Online using $($global:Office365Credentials.username) .."
        $global:Session365 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/PowerShell-LiveID -Credential $global:Office365Credentials -Authentication Basic -AllowRedirection -PSSessionOption $global:SessionExchangeOptions
    }
    Else {
        Write-Host "Connecting to Exchange Online using $($global:Office365Credentials.username) with MFA support .."
        $global:Session365 = New-ExoPSSession -ConnectionUri https://outlook.office365.com/PowerShell-LiveID -UserPrincipalName ($global:Office365Credentials).UserName
    }
    If( $global:Session365 ) {Import-PSSession -Session $global:Session365 -AllowClobber}
}

function global:Connect-ExchangeOnPremises {
    If( !($global:OnPremisesCredentials)) { Get-OnPremisesCredentials }
    If( !($global:ExchangeOnPremisesFQDN)) { Get-ExchangeOnPremisesFQDN }
    Write-Host "Connecting to Exchange On-Premises $($global:ExchangeOnPremisesFQDN) using $($global:OnPremisesCredentials.username) .."
    $global:SessionExchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($global:ExchangeOnPremisesFQDN)/PowerShell" -Credential $global:OnPremisesCredentials -Authentication Kerberos -AllowRedirection -SessionOption $global:SessionExchangeOptions
    If( $global:SessionExchange) {Import-PSSession -Session $global:SessionExchange -AllowClobber}
}

Function global:Get-ExchangeOnPremisesFQDN {
        $global:ExchangeOnPremisesFQDN = Read-Host -Prompt 'Enter Exchange On-Premises endpoint, e.g. exchange1.contoso.com'
}

function global:Connect-ComplianceCenter {
    If( !($global:Office365Credentials)) { Get-Office365Credentials }
    Write-Host "Connecting to Office 365 Compliance Center using $($global:Office365Credentials.username) .."
    $global:SessionCC = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $global:Office365Credentials -Authentication Basic -AllowRedirection   
    If( $global:SessionCC ){Import-PSSession -Session $global:SessionCC -AllowClobber}
}
 
function global:Connect-EOP {
    If ( !($global:Office365Credentials)) { Get-Office365Credentials }
    Write-Host  -InputObject "Connecting to Exchange Online Protection using $($global:Office365Credentials.username) .."
    $global:SessionEOP = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.protection.outlook.com/powershell-liveid/ -Credential $global:Office365Credentials -Authentication Basic -AllowRedirection   
    If( $global:SessionEOP ){Import-PSSession -Session $global:SessionEOP -AllowClobber}
}

function global:Connect-AzureAD {
    param([string]$AzureEnvironment)
    If( !(Get-Module -Name MSOnline)) {Import-Module -Name MSOnline -ErrorAction SilentlyContinue}
    If( Get-Module -Name MSOnline) {
        If( !($global:Office365Credentials)) { Get-Office365Credentials }
        Write-Host "Connecting to Azure Active Directory using $($global:Office365Credentials.username) .."
        If( $AzureEnvironment) {
            Connect-MsolService -Credential $global:Office365Credentials -AzureEnvironment $AzureEnvironment
        }
        Else {
            Connect-MsolService -Credential $global:Office365Credentials 
        }
    }
    Else {Write-Error -Message 'Cannot connect to Azure Active Directory - problem loading module.'}
}

function global:Connect-AzureRMS {
    If( !(Get-Module -Name AADRM)) {Import-Module -Name AADRM -ErrorAction SilentlyContinue}
    If( Get-Module -Name AADRM) {
        If( !($global:Office365Credentials)) { Get-Office365Credentials }
        Write-Host "Connecting to Azure RMS using $($global:Office365Credentials.username) .."
        Connect-AadrmService -Credential $global:Office365Credentials
    }
    Else {Write-Error -Message 'Cannot connect to Azure RMS - problem loading module.'}
}

function global:Connect-SkypeOnline {
    If( !(Get-Module -Name LyncOnlineConnector)) {Import-Module -Name LyncOnlineConnector -ErrorAction SilentlyContinue}
    If( Get-Module -Name LyncOnlineConnector) {
        If( !($global:Office365Credentials)) { Get-Office365Credentials }
        Write-Host "Connecting to Skype for Business Online using $($global:Office365Credentials.username) .."
        $global:SessionSFB = New-CsOnlineSession -Credential $global:Office365Credentials
        If( $global:SessionSFB ) {Import-PSSession -Session $global:SessionSFB -AllowClobber}
    }
    Else {Write-Error -Message 'Cannot connect to Skype for Business Online - problem loading module.'}
}

function global:Connect-SharePointOnline {
    If( !(Get-Module -Name Microsoft.Online.Sharepoint.PowerShell)) {Import-Module -Name Microsoft.Online.Sharepoint.PowerShell -ErrorAction SilentlyContinue}
    If( Get-Module -Name Microsoft.Online.Sharepoint.PowerShell) {
        If( !($global:Office365Credentials)) { Get-Office365Credentials }
        Write-Host "Connecting to SharePoint Online using $($global:Office365Credentials.username) .."
        If (($global:Office365Credentials).username -like '*.onmicrosoft.com') {$global:Office365Tenant = ($global:Office365Credentials).username.Substring(($global:Office365Credentials).username.IndexOf('@') + 1).Replace('.onmicrosoft.com', '')}
        Else {If( !($global:Office365Tenant)) { Get-Office365Tenant }}
        Connect-SPOService -url "https://$($global:Office365Tenant)-admin.sharepoint.com" -Credential $global:Office365Credentials
    }
    Else {Write-Error -Message 'Cannot connect to SharePoint Online - problem loading module.'}
}

Function global:Get-Office365Credentials {
    If( !(Get-Module -Name 'Microsoft.Exchange.Management.ExoPowershellModule' )) {
        $global:Office365Credentials = $host.ui.PromptForCredential('Office 365 Credentials', 'Please Enter Your Office 365 Credentials','','')
    }
    Else {
        $global:Office365Credentials = $host.ui.PromptForCredential('Office 365 Credentials', 'Please Enter Your Office 365 Username','','')
    }
}

Function global:Get-OnPremisesCredentials {
        $global:OnPremisesCredentials = $host.ui.PromptForCredential('On-Premises Credentials', 'Please Enter Your On-Premises Credentials','','')
}

Function global:Get-ExchangeOnPremisesFQDN {
        $global:ExchangeOnPremisesFQDN = Read-Host -Prompt 'Enter Exchange On-Premises endpoint, e.g. exchange1.contoso.com'
}

Function global:Get-Office365Tenant {
        $global:Office365Tenant = Read-Host -Prompt 'Enter tenant ID, e.g. contoso for contoso.onmicrosoft.com'
}

function global:Connect-Office365 {
    Connect-AzureAD
    Connect-AzureRMS
    Connect-ExchangeOnline
    Connect-SkypeOnline
    Connect-EOP
    Connect-ComplianceCenter
    Connect-SharePointOnline
}

#MSOLSIA
If( Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSOIdentityCRL -Name MSOIDCRLVersion -ErrorAction SilentlyContinue) {
        Write-Host 'Microsoft Online Sign-In Assistant installed' -ForegroundColor Green
}
Else {
        Write-Warning -Message "Microsoft Online Sign-In Assistant is not installed.`nThis is required for the Azure Active Directory module.`nYou can download the Microsoft Online Services Sign-In Assistant from:`nhttps://www.microsoft.com/en-us/download/confirmation.aspx?id=39267&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1"
}

#Scan for Exchange MFA PowerShell module presence
$local:ExchangeMFAModule= 'Microsoft.Exchange.Management.ExoPowershellModule'
$local:ModuleList = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "$($local:ExchangeMFAModule).manifest" -Recurse )
If( $local:ModuleList) {
    $local:ModuleName =  Join-path $local:ModuleList[0].Directory.FullName "$($local:ExchangeMFAModule).dll"
    $local:ModuleVersion= (Get-Item -Path $local:ModuleName).VersionInfo.ProductVersion
    Write-Host "Exchange Multi-Factor Authentication PowerShell Module installed (version $($local:ModuleVersion))" -ForegroundColor Green
    Import-Module -FullyQualifiedName $local:ModuleName  -Force 
}
Else {
    Write-Verbose -Message 'Exchange Multi-Factor Authentication PowerShell Module is not installed.`nnou can download the module from your tenant through a link provided on the Exchange Control Panel > Hybrid'
}

ForEach( $local:Function in $local:Functions) {
    $local:Item = ($local:Function).split('|')
    If( !($local:Item[3]) -or ( Get-Module -Name $local:Item[3] -ListAvailable)) {
        If( $local:CreateISEMenu) {
            $local:MenuObj = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus | Where-Object -FilterScript { $_.DisplayName -eq $local:Item[0] }
            If( !( $local:MenuObj)) { 
                Try {$local:MenuObj = $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add( $local:Item[0], $null, $null)}
                Catch {Write-Warning -Message $_}
            }
            Try{
                $local:RemoveItems = $local:MenuObj.Submenus |  Where-Object -FilterScript { $_.DisplayName -eq $local:Item[1] -or $_.Action -eq $local:Item[2] }
                $null = $local:RemoveItems |
                ForEach-Object -Process { $local:MenuObj.Submenus.Remove( $_) }
                $null = $local:MenuObj.SubMenus.Add( $local:Item[1], [ScriptBlock]::Create( $local:Item[2]), $null)
            }
            Catch {Write-Warning -Message $_}
        }
        If( $local:Item[3]) {
            $local:Module= Get-Module $local:Item[3] -ListAvailable
            $local:Version= ($local:Module).Version
            Write-Host "$($local:Item[4]) module installed (version $($local:Version))" -ForegroundColor Green
        }
    }
    Else {
            Write-Host "$($local:Item[4]) module not detected, link: $($local:Item[5])" -ForegroundColor Yellow
    }
}

