﻿#################################################################################################################
###                                                                                                           ###
###  	Script by Terry Munro -                                                                               ###
###     Technical Blog -               http://365admin.com.au                                                 ###
###     Webpage -                      https://www.linkedin.com/in/terry-munro/                               ###
###     TechNet Gallery Scripts -      http://tinyurl.com/TerryMunroTechNet                                   ###
###                                                                                                           ###
###     TechNet Download link -        https://gallery.technet.microsoft.com/Office-365-Connection-47e03052   ###
###                                                                                                           ###
###     Version 1.1 - 20/04/2017                                                                              ### 
###     Version 1.2 - 28/04/2017 - Added Skype For Business MFA                                               ###
###     Version 1.3 - 01/07/2017 - Added variable for tenant name and UPN                                     ###
###     Version 2.0 - 22/07/2017 - Major upgrade with Windows Form GUI                                        ### 
###                                                                                                           ###
#################################################################################################################


####  Notes for Usage  #####################################################################################################################
#                                                                                                                                          #
#  Ensure you update the variable script with your tenant name                                                                             #
#  The tenant name is used in the SharePoint Online section for SharePoint connection URL                                                  # 
#                                                                                                                                          #
#  Thanks to Scine for the Exchange Online component -                                                                                     #
#  https://github.com/Scine/Powershell/blob/master/Connect%20To%20Powershell%20with%20or%20without%202%20form%20factor%20auth%20enabled    #
#                                                                                                                                          #
#  Thanks to Steven Winston-Brown for guidance on getting Skype for Business PowerShell MFA working                                        #
#  - - https://www.linkedin.com/in/steve-winston-brown/                                                                                    #
#                                                                                                                                          #
#  Support Guides -                                                                                                                        #
#   - Pre-Requisites -                                                                                                                     #
#                                                                                                                                          #
#   - - Configure your PC for Office 365 Admin inculding MFA -                                                                             #
#   - - - http://www.365admin.com.au/2017/01/how-to-configure-your-desktop-pc-for.html                                                     #
#                                                                                                                                          #
#   - - How to enable MFA (Multi-Factor Authentication) for Office 365 administrators                                                      #
#   - - - http://www.365admin.com.au/2017/07/how-to-enable-mfa-multi-factor.html                                                           #
#                                                                                                                                          #
#   - - How to connect to Office 365 via PowerShell with MFA - Multi-Factor Authentication                                                 #
#   - - -http://www.365admin.com.au/2017/07/how-to-connect-to-office-365-via.html                                                          # 
#                                                                                                                                          #
#                                                                                                                                          #
############################################################################################################################################

$Tenant = "tenant"
$UPN = "sean.connealy.admin@SonyMusicEntertainment.onmicrosoft.com"


#----------------------------------------------
# Generated Form Function
#----------------------------------------------
function Show-ConnectWithModernAuth-v1-0_psf {

	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load('System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Data, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
	[void][reflection.assembly]::Load('System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
	#endregion Import Assemblies

	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$formConnectToOffice365Us = New-Object 'System.Windows.Forms.Form'
	$buttonTechnicalBlog = New-Object 'System.Windows.Forms.Button'
	$buttonTechNetGallery = New-Object 'System.Windows.Forms.Button'
	$textbox1 = New-Object 'System.Windows.Forms.TextBox'
	$buttonSupportURLs = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToAzureRights = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToAzureResour = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToAzureADV2 = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToAzureADV1 = New-Object 'System.Windows.Forms.Button'
	$button2 = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToSharePointO = New-Object 'System.Windows.Forms.Button'
	$buttonConnectToExchangeOnl = New-Object 'System.Windows.Forms.Button'
	$buttonOK = New-Object 'System.Windows.Forms.Button'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects

	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------

	$formConnectToOffice365Us_Load={
		#TODO: Initialize Form Controls here
		
	}
	
	$buttonConnectToExchangeOnl_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Exchange Online"
		
		Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse).FullName | Where-Object{ $_ -notmatch "_none_" } | Select-Object -First 1)
		$EXOSession = New-ExoPSSession -UserPrincipalName $UPN
		Import-PSSession $EXOSession -AllowClobber

		Write-Host "Completed running the script to Connect to Exchange Online - Run the cmdlet - Get-Mailbox - to test connection"
		
	}
	
	$buttonConnectToSharePointO_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to SharePoint Online"
		
		Connect-SPOService -Url https://$($Tenant)-admin.sharepoint.com
		
		Write-Host "Completed running the script to Connect to SharePoint Online - Run the cmdlet - Get-SPOTenant - to test connection"
		
	}
	
	$button2_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Skype for Business Online"
		
		Import-Module SkypeOnlineConnector
		$SFBOSession = New-CsOnlineSession -UserName $UPN
		Import-PSSession $SFBOSession -AllowClobber
		
		Write-Host "Completed running the script to Connect to Skype for Business Online - Run the cmdlet - Get-CSTenant - to test connection"
		
	}
	
	$buttonConnectToAzureADV1_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Azure Active Directory v1"
		
		Connect-MsolService
		
		Write-Host "Completed running the script to Azure Active Directory v1 - Run the cmdlet - Get-MSOLUser - to test connection"
		
	}
	
	$buttonConnectToAzureADV2_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Azure Active Directory v2"
		
		Connect-AzureAD
		
		Write-Host "Completed running the script to Azure Active Directory v2 - Run the cmdlet - Get-AzureADUser - to test connection"
		
	}
	
	$buttonConnectToAzureResour_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Azure Resource Manager"
		
		Login-AzureRmAccount
		
		Write-Host "Completed running the script to Azure Resource Manager - Run the cmdlet - Get-AzureRMContext - to test connection"
		
	}
	
	$buttonConnectToAzureRights_Click={
		#TODO: Place custom script here
		
		Write-Host "Running the script to Connect to Azure Rights Management"
		
		Connect-AadrmService
		Import-Module AADRM
		
		Write-Host "Completed running the script to Azure Rights Management - Run the cmdlet - Get-AADRM - to test connection"
		
	}
	
	$textbox1_TextChanged={
		#TODO: Place custom script here
		
	}
	
	$buttonTechNetGallery_Click={
		#TODO: Place custom script here
		
		Start-Process -FilePath https://tinyurl.com/TerryMunroTechnet
		
	}
	
	$buttonTechnicalBlog_Click={
		#TODO: Place custom script here
		
		Start-Process -FilePath http://365admin.com.au
		
	}
	
	$buttonSupportURLs_Click={
		#TODO: Place custom script here
		
		Start-Process -FilePath http://www.365admin.com.au/2017/07/all-mfa-multi-factor-authentication.html
		
	}
	
	# --End User Generated Script--
	#----------------------------------------------
	#region Generated Events
	#----------------------------------------------
	
	$Form_StateCorrection_Load=
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$formConnectToOffice365Us.WindowState = $InitialFormWindowState
	}
	
	$Form_Cleanup_FormClosed=
	{
		#Remove all event handlers from the controls
		try
		{
			$buttonTechnicalBlog.remove_Click($buttonTechnicalBlog_Click)
			$buttonTechNetGallery.remove_Click($buttonTechNetGallery_Click)
			$textbox1.remove_TextChanged($textbox1_TextChanged)
			$buttonSupportURLs.remove_Click($buttonSupportURLs_Click)
			$buttonConnectToAzureRights.remove_Click($buttonConnectToAzureRights_Click)
			$buttonConnectToAzureResour.remove_Click($buttonConnectToAzureResour_Click)
			$buttonConnectToAzureADV2.remove_Click($buttonConnectToAzureADV2_Click)
			$buttonConnectToAzureADV1.remove_Click($buttonConnectToAzureADV1_Click)
			$button2.remove_Click($button2_Click)
			$buttonConnectToSharePointO.remove_Click($buttonConnectToSharePointO_Click)
			$buttonConnectToExchangeOnl.remove_Click($buttonConnectToExchangeOnl_Click)
			$formConnectToOffice365Us.remove_Load($formConnectToOffice365Us_Load)
			$formConnectToOffice365Us.remove_Load($Form_StateCorrection_Load)
			$formConnectToOffice365Us.remove_FormClosed($Form_Cleanup_FormClosed)
		}
		catch { Out-Null <# Prevent PSScriptAnalyzer warning #> }
	}
	#endregion Generated Events

	#----------------------------------------------
	#region Generated Form Code
	#----------------------------------------------
	$formConnectToOffice365Us.SuspendLayout()
	#
	# formConnectToOffice365Us
	#
	$formConnectToOffice365Us.Controls.Add($buttonTechnicalBlog)
	$formConnectToOffice365Us.Controls.Add($buttonTechNetGallery)
	$formConnectToOffice365Us.Controls.Add($textbox1)
	$formConnectToOffice365Us.Controls.Add($buttonSupportURLs)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToAzureRights)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToAzureResour)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToAzureADV2)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToAzureADV1)
	$formConnectToOffice365Us.Controls.Add($button2)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToSharePointO)
	$formConnectToOffice365Us.Controls.Add($buttonConnectToExchangeOnl)
	$formConnectToOffice365Us.Controls.Add($buttonOK)
	$formConnectToOffice365Us.AcceptButton = $buttonOK
	$formConnectToOffice365Us.AutoScaleDimensions = '6, 13'
	$formConnectToOffice365Us.AutoScaleMode = 'Font'
	$formConnectToOffice365Us.BackColor = 'Window'
	$formConnectToOffice365Us.ClientSize = '805, 408'
	$formConnectToOffice365Us.FormBorderStyle = 'FixedDialog'
	$formConnectToOffice365Us.MaximizeBox = $False
	$formConnectToOffice365Us.MinimizeBox = $False
	$formConnectToOffice365Us.Name = 'formConnectToOffice365Us'
	$formConnectToOffice365Us.StartPosition = 'CenterScreen'
	$formConnectToOffice365Us.Text = 'Connect to Office 365 using Modern Auth and MFA - By Terry Munro - 365admin.com.au'
	$formConnectToOffice365Us.add_Load($formConnectToOffice365Us_Load)
	#
	# buttonTechnicalBlog
	#
	$buttonTechnicalBlog.BackColor = 'Window'
	$buttonTechnicalBlog.Location = '591, 311'
	$buttonTechnicalBlog.Name = 'buttonTechnicalBlog'
	$buttonTechnicalBlog.Size = '130, 43'
	$buttonTechnicalBlog.TabIndex = 12
	$buttonTechnicalBlog.Text = 'Technical Blog'
	$buttonTechnicalBlog.UseVisualStyleBackColor = $False
	$buttonTechnicalBlog.add_Click($buttonTechnicalBlog_Click)
	#
	# buttonTechNetGallery
	#
	$buttonTechNetGallery.BackColor = 'Window'
	$buttonTechNetGallery.Location = '591, 250'
	$buttonTechNetGallery.Name = 'buttonTechNetGallery'
	$buttonTechNetGallery.Size = '130, 43'
	$buttonTechNetGallery.TabIndex = 11
	$buttonTechNetGallery.Text = 'TechNet Gallery'
	$buttonTechNetGallery.UseVisualStyleBackColor = $False
	$buttonTechNetGallery.add_Click($buttonTechNetGallery_Click)
	#
	# textbox1
	#
	$textbox1.BackColor = 'Window'
	$textbox1.Location = '560, 149'
	$textbox1.Name = 'textbox1'
	$textbox1.Size = '190, 20'
	$textbox1.TabIndex = 9
	$textbox1.Text = 'Support Links'
	$textbox1.TextAlign = 'Center'
	$textbox1.add_TextChanged($textbox1_TextChanged)
	#
	# buttonSupportURLs
	#
	$buttonSupportURLs.BackColor = 'Window'
	$buttonSupportURLs.Location = '591, 188'
	$buttonSupportURLs.Name = 'buttonSupportURLs'
	$buttonSupportURLs.Size = '130, 43'
	$buttonSupportURLs.TabIndex = 8
	$buttonSupportURLs.Text = 'Support URLs'
	$buttonSupportURLs.UseVisualStyleBackColor = $False
	$buttonSupportURLs.add_Click($buttonSupportURLs_Click)
	#
	# buttonConnectToAzureRights
	#
	$buttonConnectToAzureRights.BackColor = 'Control'
	$buttonConnectToAzureRights.DialogResult = 'OK'
	$buttonConnectToAzureRights.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToAzureRights.Location = '302, 272'
	$buttonConnectToAzureRights.Name = 'buttonConnectToAzureRights'
	$buttonConnectToAzureRights.Size = '190, 82'
	$buttonConnectToAzureRights.TabIndex = 7
	$buttonConnectToAzureRights.Text = 'Connect to Azure Rights Manager'
	$buttonConnectToAzureRights.UseVisualStyleBackColor = $False
	$buttonConnectToAzureRights.add_Click($buttonConnectToAzureRights_Click)
	#
	# buttonConnectToAzureResour
	#
	$buttonConnectToAzureResour.BackColor = 'Control'
	$buttonConnectToAzureResour.DialogResult = 'OK'
	$buttonConnectToAzureResour.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToAzureResour.Location = '53, 272'
	$buttonConnectToAzureResour.Name = 'buttonConnectToAzureResour'
	$buttonConnectToAzureResour.Size = '190, 82'
	$buttonConnectToAzureResour.TabIndex = 6
	$buttonConnectToAzureResour.Text = 'Connect to Azure Resource Manager'
	$buttonConnectToAzureResour.UseVisualStyleBackColor = $False
	$buttonConnectToAzureResour.add_Click($buttonConnectToAzureResour_Click)
	#
	# buttonConnectToAzureADV2
	#
	$buttonConnectToAzureADV2.BackColor = 'Control'
	$buttonConnectToAzureADV2.DialogResult = 'OK'
	$buttonConnectToAzureADV2.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToAzureADV2.Location = '302, 149'
	$buttonConnectToAzureADV2.Name = 'buttonConnectToAzureADV2'
	$buttonConnectToAzureADV2.Size = '190, 82'
	$buttonConnectToAzureADV2.TabIndex = 5
	$buttonConnectToAzureADV2.Text = 'Connect to Azure AD v2'
	$buttonConnectToAzureADV2.UseVisualStyleBackColor = $False
	$buttonConnectToAzureADV2.add_Click($buttonConnectToAzureADV2_Click)
	#
	# buttonConnectToAzureADV1
	#
	$buttonConnectToAzureADV1.BackColor = 'Control'
	$buttonConnectToAzureADV1.DialogResult = 'OK'
	$buttonConnectToAzureADV1.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToAzureADV1.Location = '53, 149'
	$buttonConnectToAzureADV1.Name = 'buttonConnectToAzureADV1'
	$buttonConnectToAzureADV1.Size = '190, 82'
	$buttonConnectToAzureADV1.TabIndex = 4
	$buttonConnectToAzureADV1.Text = 'Connect to Azure AD v1'
	$buttonConnectToAzureADV1.UseVisualStyleBackColor = $False
	$buttonConnectToAzureADV1.add_Click($buttonConnectToAzureADV1_Click)
	#
	# button2
	#
	$button2.BackColor = 'Control'
	$button2.DialogResult = 'OK'
	$button2.Font = 'Microsoft Sans Serif, 11.25pt'
	$button2.Location = '560, 33'
	$button2.Name = 'button2'
	$button2.Size = '190, 82'
	$button2.TabIndex = 3
	$button2.Text = 'Connect to Skype for Business Online'
	$button2.UseVisualStyleBackColor = $False
	$button2.add_Click($button2_Click)
	#
	# buttonConnectToSharePointO
	#
	$buttonConnectToSharePointO.BackColor = 'Control'
	$buttonConnectToSharePointO.DialogResult = 'OK'
	$buttonConnectToSharePointO.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToSharePointO.Location = '302, 33'
	$buttonConnectToSharePointO.Name = 'buttonConnectToSharePointO'
	$buttonConnectToSharePointO.Size = '190, 82'
	$buttonConnectToSharePointO.TabIndex = 2
	$buttonConnectToSharePointO.Text = 'Connect to SharePoint Online'
	$buttonConnectToSharePointO.UseVisualStyleBackColor = $False
	$buttonConnectToSharePointO.add_Click($buttonConnectToSharePointO_Click)
	#
	# buttonConnectToExchangeOnl
	#
	$buttonConnectToExchangeOnl.BackColor = 'Control'
	$buttonConnectToExchangeOnl.DialogResult = 'OK'
	$buttonConnectToExchangeOnl.Font = 'Microsoft Sans Serif, 11.25pt'
	$buttonConnectToExchangeOnl.Location = '53, 33'
	$buttonConnectToExchangeOnl.Name = 'buttonConnectToExchangeOnl'
	$buttonConnectToExchangeOnl.Size = '190, 82'
	$buttonConnectToExchangeOnl.TabIndex = 1
	$buttonConnectToExchangeOnl.Text = 'Connect to Exchange Online'
	$buttonConnectToExchangeOnl.UseVisualStyleBackColor = $False
	$buttonConnectToExchangeOnl.add_Click($buttonConnectToExchangeOnl_Click)
	#
	# buttonOK
	#
	$buttonOK.Anchor = 'Bottom, Right'
	$buttonOK.DialogResult = 'OK'
	$buttonOK.Location = '718, 373'
	$buttonOK.Name = 'buttonOK'
	$buttonOK.Size = '75, 23'
	$buttonOK.TabIndex = 0
	$buttonOK.Text = '&OK'
	$buttonOK.UseVisualStyleBackColor = $True
	$formConnectToOffice365Us.ResumeLayout()
	#endregion Generated Form Code

	#----------------------------------------------

	#Save the initial state of the form
	$InitialFormWindowState = $formConnectToOffice365Us.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$formConnectToOffice365Us.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$formConnectToOffice365Us.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $formConnectToOffice365Us.ShowDialog()

} #End Function

#Call the form
Show-ConnectWithModernAuth-v1-0_psf | Out-Null
