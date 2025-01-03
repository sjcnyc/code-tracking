#################################################################################################################
###                                                                                                           ###
###  	Script by Terry Munro -                                                                               ###
###     Technical Blog -               http://365admin.com.au                                                 ###
###     GitHub Repository -            http://github.com/TeamTerry                                            ###
###     TechNet Gallery Scripts -      http://tinyurl.com/TerryMunroTechNet                                   ###
###     Webpage -                      http://docs.com/terry-munro                                            ###
###     Version 1.0 - 07/02/2017                                                                              ###
###     Version 2.0 - 15/4/2017                                                                               ### 
###     Revision - Added connection to other services and load modules                                        ###
###  	Created with the follow links as reference                                                            ###
###     - http://powershellblogger.com/2016/02/connect-to-all-office-365-services-with-powershell/            ###
###     - https://technet.microsoft.com/en-us/library/dn568015.aspx                                           ###
###                                                                                                           ###
###                                                                                                           ###
#################################################################################################################

####  Notes for Usage  ######################################################################
#                                                                                           #
#  Ensure you update the script with your tenant name and username                          #
#  Your username is in the Exchange Online section for Get-Credential                       #
#  The tenant name is used in the Exchange Online section for Get-Credential                #
#  The tenant name is used in the SharePoint Online section for SharePoint connection URL   # 
#                                                                                           #
#  Support Guides -                                                                         #
#   - Pre-Requisites -                                                                      #
#   - - - http://www.365admin.com.au/2017/01/how-to-configure-your-desktop-pc-for.html      #      
#   - Usage Guide -                                                                         # 
#   - - - http://www.365admin.com.au/2017/01/how-to-connect-to-office-365-via.html          #
#                                                                                           #
#############################################################################################


###   Exchange Online
$cred = Get-credential "admin@tenant.onmicrosoft.com"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
Import-Module MsOnline
Connect-MsolService -Credential $cred


###  SharePoint Online
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://tenant-admin.sharepoint.com -Credential $cred


### Skype Online
Import-Module LyncOnlineConnector
Import-Module SkypeOnlineConnector
$SkypeSession = New-CsOnlineSession -Credential $cred
Import-PSSession $SkypeSession


### Azure AD v2.0
Connect-AzureAD -Credential $cred


### Compliance Center
$ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $cred -Authentication "Basic" -AllowRedirection
Import-PSSession $ccSession -Prefix cc


### Exchange Online Protection
$EOPSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.protection.outlook.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $EOPSession -AllowClobber


### Azure Resource Manager
Login-AzureRmAccount -Credential $cred
Clear-Host