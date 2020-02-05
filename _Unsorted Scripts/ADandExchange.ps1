
<#PSScriptInfo

.VERSION 1.2

.GUID 14f375d0-23e0-4c58-a6d3-da7cc1ecbdf1

.AUTHOR administrator

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Just upload 

#> 

Param()


#Mostly Created by Chris Loonan
#www.linkedin.com/in/chris-loonan-950b3811a

#Submenu format created by Jon Dechiro at this link
# https://stackoverflow.com/questions/38924659/powershell-multi-choice-menu-and-sub-menu

#MFA login created by Jos.Verlinde
#https://www.powershellgallery.com/packages/Load-ExchangeMFA/1.2/DisplayScript

<## TO DO ##
Add error checking and conditions to Exchange logout #
Add more exchange commands
Add Recycling bin prompt for returning deleted users
Add Script to enable and check Encryption #>

### All comments Correspond with code directly below. Never Above ###

function mainMenu {
    $mainMenu = 'X'
    while($mainMenu -ne ''){
        Clear-Host
		#white Title at the top 
        Write-Host "`n`t`t Chris Loonan PowerShell Extravaganza`n"
		#Main Menu Options
        Write-Host -ForegroundColor Cyan "Main Menu"
		
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Active Directory Commands"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Exchange Online Commands"
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Connect to Office 365."
        $mainMenu = Read-Host "`nSelection (Press enter for previous menu)"
        # Launch submenu1
        if($mainMenu -eq 1){
            subMenu1
        }
        # Launch submenu2
        if($mainMenu -eq 2){
            subMenu2
        }
		#Launch submenu3
		if($mainmenu -eq 3){
			subMenu3
		}
    }
}
#####################SUBMENU 1#############################
function subMenu1 {
    $subMenu1 = 'X'
    while($subMenu1 -ne ''){
        Clear-Host
        Write-Host "`n`t`t Active Directory Commands`n"
		
        Write-Host -ForegroundColor Cyan "Sub Menu 1"
		
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Return all active Directory users On Premise"
			
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Return Deleted Users"
			
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Script to remove Duplicate users"
		
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "4"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Full Sync"
			
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "5"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Delta Sync"
			
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "6"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " AD Diagnostic Tools (Well it's one tool but it does a bunch of stuff)"
	    Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "7"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Set Custom Sync Scheduler"	
			
        $subMenu1 = Read-Host "`nSelection (Press enter for previous menu)"
		# I don't know what this does and at this point I'm afraid to get rid of it.
        #$timeStamp = Get-Date -Uformat %m%d%y%H%M
        # Option 1 Just returns every user might make it better by having user prompt for filter
        if($subMenu1 -eq 1){
		    Get-aduser -filter * | more
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button. I think I deleted it once and it still did it so I don't know
            [void][System.Console]::ReadKey($true)
        }
        # Option 2 This returns all deleted user. Will add recycling bin parameter too
        if($subMenu1 -eq 2){
            $deleted=Get-ADObject -ldapFilter:"(msDS-LastKnownRDN=*)" -IncludeDeletedObjects
			$deleted
			Get-ADObject -ldapFilter:"(msDS-LastKnownRDN=*)" -IncludeDeletedObjects
			# Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
           exit
        }
		# Option 3
		#This removes any duplicate users that may have been created	
		if($submenu1 -eq 3){
			if ($Credential -ne $null) { 
				$networkCred = $Credential.GetNetworkCredential() 
				$ldapDirectoryIdentifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($targetDomainFqdn, 3268) 
				$ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapDirectoryIdentifier,$networkCred) 
			} 
			else 
				{ 
				$ldapDirectoryIdentifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($targetDomainFqdn, 3268) 
				$ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapDirectoryIdentifier) 
				} 
			Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
            [void][System.Console]::ReadKey($true)
		}
		# Option 4
		if($subMenu1 -eq 4){
			
			Write-Host -ForegroundColor Yellow "`n Running: Start-ADSyncSyncCycle -PolicyType Initial"
            Start-ADSyncSyncCycle -PolicyType Initial
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
            [void][System.Console]::ReadKey($true)
        }
		# Option 5
		if($subMenu1 -eq 5){
			Write-Host -ForegroundColor Yellow " `nDelta Sync in Progress. Please Wait"
            Start-ADSyncSyncCycle -PolicyType Delta
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
            [void][System.Console]::ReadKey($true)
        }
		# Option 6
		if($subMenu1 -eq 6){
			Write-Host -ForegroundColor Yellow "`nInvoke-ADSyncDiagnostics -PasswordSync"
			Set-ExecutionPolicy RemoteSigned
			Import-Module AdsyncDiagnostics
			Invoke-ADSyncDiagnostics -PasswordSync
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor Green "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
            [void][System.Console]::ReadKey($true)
        }
		# Option 7
		if($subMenu1 -eq 7){
            $time=read-Host "How often do you want to sync? (HH:MM:SS)"
			Set-ADSyncScheduler -CustomizedSyncCycleInterval $time
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
			#This forces the script to pause and wait for a user to press a button
            [void][System.Console]::ReadKey($true)
        }
	}
}
#######################SUBMENU2######################################
function subMenu2 {
    $subMenu2 = 'X'
	#this keeps the submenu open as long as the user does not type nothing
    while($subMenu2 -ne ''){
        Clear-Host
        Write-Host "`n`t`t Exchange Commands`n"
        Write-Host -ForegroundColor Cyan "Exchange Submenu"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Exchange Server Login"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Exchange Server Logout (Barely works)"
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Get Mailbox Information for a user"
		Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "4"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " MFA Login"
			
        $subMenu2 = Read-Host "`nSelection (Press enter for previous menu)"
        $timeStamp = Get-Date -Uformat %m%d%y%H%M
        # Option 1
        if($subMenu2 -eq 1){
			#this removes any previous session so it will not cause issues when logging in
			Get-PSSession | Remove-PSSession
			$i = 0
			for(){
				Try{
					if($i -ne 0){
						Write-Host -NoNewLine 'You messed something up, login again...'
						$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
					}
					$UserCredential = Get-Credential
					
					$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
					Import-PSSession $Session
					break
				}
					catch [System.Management.Automation.Remoting.PSRemotingTransportException],[System.Management.Automation.ParameterBindingException]{
					
					if($i -eq 3){
								return
					}
				}
				$i = $i + 1
			}
			Write-Host -ForeGroundColor Yellow "`nLogin Successfull "
			exit
			#This launches a new session that will link the login the user uses to be the domain it connects to
			########$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
			
            # Pause and wait for input before going back to the menu
            #Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            #This forces the script to pause and wait for a user to press a button
			[void][System.Console]::ReadKey($true)
					
			
        }
		
        # Option 2
        if($subMenu2 -eq 2){
			
            Write-Host "`n Exchange Logout (Broken. Close out of powershell completely)"
			Remove-PSSession *
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor Yellow "`n`n TEST You have logged out of your Exchange Management Console."
            Write-Host "`nPress any key to return to the previous menu"
            #This forces the script to pause and wait for a user to press a button
			[void][System.Console]::ReadKey($true)
        }
		if($subMenu2 -eq 3){
			$MailUser=read-Host "`nWhat is the name of the user?"
			Get-Mailbox -Identity $MailUser | Select-Object *
			Write-Host "`nPress any key to return to the previous menu"
            #This forces the script to pause and wait for a user to press a button
			[void][System.Console]::ReadKey($true)
		}
		if($submenu2 -eq 4){
		
			Write-Host "`nExchange Multifactor Authentication Login."
				function Install-Cmdlet {
				[CmdletBinding()] 
				Param(
					$Manifest = "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application",
					#AssertApplicationRequirements
					$ElevatePermissions = $true
				)
					Try { 
						Add-Type -AssemblyName System.Deployment
						
						Write-Verbose "Start installation of ClockOnce Application $Manifest "

						$RemoteURI = [URI]::New( $Manifest , [UriKind]::Absolute)
						if (-not  $Manifest)
						{
							throw "Invalid ConnectionUri parameter '$ConnectionUri'"
						}

						$HostingManager = New-Object System.Deployment.Application.InPlaceHostingManager -ArgumentList $RemoteURI , $False
					
						#register an event to trigger custom event (yep, its a hack) 
						Register-ObjectEvent -InputObject $HostingManager -EventName GetManifestCompleted -Action { 
							new-event -SourceIdentifier "ManifestDownloadComplete"
						} | Out-Null
						#register an event to trigger custom event (yep, its a hack) 
						Register-ObjectEvent -InputObject $HostingManager -EventName DownloadApplicationCompleted -Action { 
							new-event -SourceIdentifier "DownloadApplicationCompleted"
						} | Out-Null

						#get the Manifest
						$HostingManager.GetManifestAsync()

						#Waitfor up to 5s for our custom event
						$event = Wait-Event -SourceIdentifier "ManifestDownloadComplete" -Timeout 5
						if ($event ) {
							$event | Remove-Event
							Write-Verbose "ClickOnce Manifest Download Completed"

							$HostingManager.AssertApplicationRequirements($ElevatePermissions)
							#todo :: can this fail ?
							
							#Download Application 
							$HostingManager.DownloadApplicationAsync()
							#register and wait for completion event 
							# $HostingManager.DownloadApplicationCompleted 
							$event = Wait-Event -SourceIdentifier "DownloadApplicationCompleted" -Timeout 15
							if ($event ) {
								$event | Remove-Event
								Write-Verbose "ClickOnce Application Download Completed"
							} else {
								Write-error "ClickOnce Application Download did not complete in time (15s)"
							}
						} else {
						   Write-error "ClickOnce Manifest Download did not complete in time (5s)"
						}

						#Clean Up 
					} finally {
						#get rid of our eventhandlers
						Get-EventSubscriber|? {$_.SourceObject.ToString() -eq 'System.Deployment.Application.InPlaceHostingManager'} | Unregister-Event
					}
				}
				<# Simple Install Check 
				#>
				function Get-ClickOnce {
				[CmdletBinding()]  
				Param(
					$ApplicationName = "Microsoft Exchange Online Powershell Module"
				)
					$InstalledApplicationNotMSI = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
					return $InstalledApplicationNotMSI | ? { $_.displayname -match $ApplicationName } | Select-Object -First 1
				}

				Function Test-ClickOnce {
				[CmdletBinding()] 
				Param(
					$ApplicationName = "Microsoft Exchange Online Powershell Module"
				)
					return ( (Get-ClickOnce -ApplicationName $ApplicationName) -ne $null) 
				}

				<# Simple UnInstall 
				#>
				function Uninstall-ClickOnce {
				[CmdletBinding()] 
				Param(
					$ApplicationName = "Microsoft Exchange Online Powershell Module"
				)
					$app=Get-ClickOnce -ApplicationName $ApplicationName

					#Deinstall One to remove all instances 
					if ($App) { 
						$selectedUninstallString = $App.UninstallString 
						#Seperate cmd from parameters (First Space) 
						$parts = $selectedUninstallString.Split(' ', 2)
						Start-Process -FilePath $parts[0] -ArgumentList $parts[1] -Wait 
						#ToDo : Automatic press of OK 
						#Start-Sleep 5
						#$wshell = new-object -com wscript.shell
						#$wshell.sendkeys("`"OK`"~")

						$app=Get-ClickOnce -ApplicationName $ApplicationName
						if ($app) {
							Write-verbose 'De-installation aborted'
							#return $false
						} else {
							Write-verbose 'De-installation completed'
							#return $true
						} 
						
					} else {
						#return $null
					}
				}

				Function Load-ExchangeMFAModule { 
				[CmdletBinding()] 
				Param ()
					$Modules = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
					if ($Modules.Count -ne 1 ) {
						throw "No or Multiple Modules found : Count = $($Modules.Count )"  
					}  else {
						$ModuleName =  Join-path $Modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
						Write-Verbose "Start Importing MFA Module"
						Import-Module -FullyQualifiedName $ModuleName  -Force 

						$ScriptName =  Join-path $Modules[0].Directory.FullName "CreateExoPSSession.ps1"
						if (Test-Path $ScriptName) {
							return $ScriptName
				<# 
							# Load the script to add the additional commandlets (Connect-EXOPSSession) 
							# DotSourcing does not work from inside a function (. $ScriptName) 
							#Therefore load the script as a dynamic module instead 
				 
							$content = Get-Content -Path $ScriptName -Raw -ErrorAction Stop 
							#BugBug >> $PSScriptRoot is Blank :-( 
				<# 
							$PipeLine = $Host.Runspace.CreatePipeline() 
							$PipeLine.Commands.AddScript(". $scriptName") 
							$r = $PipeLine.Invoke() 
				#Err : Pipelines cannot be run concurrently. 
				 
							$scriptBlock = [scriptblock]::Create($content) 
							New-Module -ScriptBlock $scriptBlock -Name "Microsoft.Exchange.Management.CreateExoPSSession.ps1" -ReturnResult -ErrorAction SilentlyContinue 
				#>

						} else {
							throw "Script not found"
							return $null
						}
					}
				}


				if ((Test-ClickOnce -ApplicationName "Microsoft Exchange Online Powershell Module" ) -eq $false)  {
				   Install-ClickOnce -Manifest "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
				}
				#Load the Module
				$script = Load-ExchangeMFAModule -Verbose
				#Dot Source the associated script
				. $Script

				#make sure the Exchange session uses the same proxy settings as IE/Edge 
				#$ProxySetting = New-PSSessionOption -ProxyAccessType IEConfig
				Connect-EXOPSSession #-PSSessionOption $ProxySetting 
							
							Write-Host "`n Press any ley to return to the previous menu"
							
							#[void][System.console]::ReadKey($true)
							}			
					}
				}

###################SUBMENU3  MSOnline 
Function subMenu3 {
	   #$subMenu3 = 'X'
		while($subMenu3 -ne ''){
        Clear-Host
        Write-Host "`n`t`t Office 365 Powershell Tools`n"
        #Write-Host -ForegroundColor Cyan "Connect to Office 365"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Connect To Office 365"
		 $subMenu3 = Read-Host "`nSelection (Press enter for previous menu)"
		if($submenu3 -eq 1){
			$usercredential = Get-Credential
			Connect-msolservice -Credential $usercredential
			Write-Host "`nPress any key to return to the previous menu"
            #This forces the script to pause and wait for a user to press a button
			[void][System.Console]::ReadKey($true)
			}	
		}#>
	}
###################MAINMENU###########################
mainMenu
