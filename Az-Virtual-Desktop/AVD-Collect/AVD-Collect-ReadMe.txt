================
IMPORTANT NOTICE 
================
 
This script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Azure Virtual Desktop.
The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses, PC names and user names.
The script will save the collected data in a subfolder and also compress the results into a ZIP file. The folder or ZIP file are not automatically sent to Microsoft. 
You can send the ZIP file to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have. 
Find our privacy statement here: https://privacy.microsoft.com/en-US/privacystatement



=============================
About AVD-Collect (v220518.3)
=============================

 • Are you running into issues with your AVD VMs?
 • Are you struggling to find the relevant logs/data on your VMs for troubleshooting or you'd just like to know which data could be helpful?
 • Would you like an easy, scripted way to collect the relevant troubleshooting data from your VMs?
 • Would you like to proactively check if your AVD VMs are configured correctly or if they are running into some known issues?

If the answer to any of these questions is 'yes', then this tool will be of great help to you!

AVD-Collect is a PowerShell script to simplify data collection for troubleshooting Azure Virtual Desktop and Windows 365 related issues and a convenient method for submitting and following quick & easy action plans. ​​​​​​​

The collected data can help with troubleshooting various AVD related issues, ranging from deployment and configuration, to session connectivity, profile (incl. FSLogix), media optimization for Teams, MSIX App Attach, Remote Assistance and more.

​​​​​​​The AVD-Diag report included in AVD-Collect can give an overall view of the deployment and quickly pinpoint several known issues, thus significantly speeding up time to resolution.



==========
How to use
==========

The script requires at least PowerShell version 5.1 and must be run with elevated permissions in order to collect all required data.

All data will be collected under C:\MSDATA\ (or in a custom location if the "-OutputDir" parameter has been specified) and also archived into a .zip file located in the same folder.
Run the script on AVD host VMs and/or Windows devices (source machines) from where you connect to the AVD hosts, as needed.

--//--
Important: 
The script has multiple module (.psm1) files located in a "Modules" folder. This folder (with its underlying .psm1 files) must stay in the same folder as the main AVD-Collect.ps1 file for the script to work properly.
Download the AVD-Collect.zip package from the official public download location (https://aka.ms/avd-collect) and extract all files from it, not just the AVD-Collect.ps1.
The script will import the required module(s) on the fly when specific data is being invoked. You do not need to manually import the modules.

When opening the AVD-Collect.ps1 using Powershell ISE (or other PowerShell GUI editors), make sure that the context of the ISE/GUI console is set to the folder that contains the AVD-Collect.ps1 script.
Leaving it to the default "C:\Windows\System32" (or any other folder that doesn't contain all the AVD-Collect files) will cause the script to fail as it will not find its modules.
So for example, if you have unzipped the entire script package under "D:\Downloads\AVD-Collect", then launched PowerShell ISE and opened the AVD-Collect.ps1 file, before executing the script, also run a "cd D:\Downloads\AVD-Collect" (or whatever location you used to store the script) in the PowerShell ISE console.
--//--


The script can be used in 3 ways:

1) with a GUI: Start the script by running ".\AVD-Collect.ps1" in an elevated PowerShell window.

2) without a GUI, but still with a selection menu (legacy mode): Start the script by running ".\AVD-Collect.ps1 -NoGUI" in an elevated PowerShell window.

3) using any combination of one or more scenario-based command line parameters, which will suppress the GUI and start the corresponding data collection. Example: ".\AVD-Collect.ps1 -Profiles -MSIXAA -Scard"


When launched, the script will:
a) present the Microsoft Diagnostic Tools End User License Agreement (EULA). You need to accept the EULA before you can continue using the script.
Acceptance of the EULA will be stored in the registry under HKCU\Software\Microsoft\CESDiagnosticTools and you will not be prompted again to accept it as long as the registry key is in place.
You can also use the "-AcceptEula" command line parameter to silently accept the EULA.
This is a per user setting, so each user running the script will have to accept the EULA once.

b) present an internal notice that the admin needs to confirm if they agree and want to continue with the data collection.


When launched with the "-NoGUI" parameter, the script will ask you to select one of the following scenarios:

	"Core" (suitable for troubleshooting issues that do not involve specific scenarios like Profiles or Teams or MSIX App Attach or Remote Assistance or Smart Card or IME or Azure Stack HCI)
		• Collects core troubleshooting data without including additional scenario-specific data
		• Runs Diagnostics and logs the results

	"Profiles" (suitable for troubleshooting Profiles issues)
		​​​​​​​• Collects core + Profiles/FSLogix/OneDrive related troubleshooting data
		• Runs Diagnostics and logs the results

	"Teams" (suitable for troubleshooting Teams issues)
		• Collects Core + Teams related troubleshooting data
		• Runs Diagnostics and logs the results

	"MSIX App Attach" (suitable for troubleshooting MSIX App Attach issues)
		• ​​​​​​​Collects Core + MSIX App Attach related troubleshooting data
		• Runs Diagnostics and logs the results

	"MSRA" (suitable for troubleshooting Remote Assistance issues)
		• Collects Core + Remote Assistance related troubleshooting data
		• Runs Diagnostics and logs the results

	"SCard" (suitable for troubleshooting Smart Card issues)
		• May prompt for smartcard PIN during data collection
		• ​​​​​​​Collects Core + Smart Card related troubleshooting data
		• Runs Diagnostics and logs the results

	"IME" (suitable for troubleshooting input method issues)
		• ​​​​​​​Collects Core + input method related troubleshooting data
		• Runs Diagnostics and logs the results
		
	"HCI" (suitable for troubleshooting Azure Stack HCI issues)
		• ​​​​​​​Collects all Core data + Azure Stack HCI related troubleshooting data
		• Runs Diagnostics and logs the results

	"DumpPID" (suitable for troubleshooting process hangs)
		• ​​​​​​​Collects all Core data + a memory dump of an active process that has the provided PID
		• Runs Diagnostics and logs the results
		
	"DiagOnly"
		• Runs Diagnostics and logs the results

The default scenario is "Core".​​​​​​​


Available command line parameters
---------------------------------

Scenario-based parameters:

	"-Core" - Collects Core data + Runs Diagnostics

	"-Profiles" - Collects all Core data + Profiles data + Runs Diagnostics

	"-Teams" - Collects all Core data + Teams data + Runs Diagnostics

	"-MSIXAA" - Collects all Core data + MSIX App Attach data + Runs Diagnostics

	"-MSRA" - Collects all Core data + Remote Assistance data + Runs Diagnostics

	"-SCard" - Collects all Core data + Smart Card/RDGW data + Runs Diagnostics

	"-IME" - Collects all Core data + input method data + Runs Diagnostics

	"-HCI" - Collects all Core data + Azure Stack HCI data + Runs Diagnostics

	"-DumpPID <pid>" - Generate a process dump based on the provided PID (This dump collection is part of the 'Core' dataset and works with any other scenario parameter except '-DiagOnly')

	"-DiagOnly" - The script will skip all data collection and will only run the diagnostics part (even if other parameters have been specified)
	

Other parameters:

	"-AcceptEula" - Silently accepts the Microsoft Diagnostic Tools End User License Agreement
	
	"-AcceptNotice" - Silently accepts the internal Important Notice message on data collection

	"-OutputDir <path>" - ​​​​​​Specify a custom directory where to store the collected files. By default, if this parameter is not specified, the script will store the collected data under "C:\MSDATA". If the path specified does not exit, the script will attempt to create it

	"-NoGUI" - Start the script without a graphical user interface (legacy mode)


You can combine multiple command line parameters to build your desired dataset.

Usage examples with parameters:

To collect only Core data (excluding Profiles, Teams, MSIX App Attach, MSRA, Smart Card, IME):
	.\AVD-Collect.ps1 -Core

To collect Core + Profiles + MSIX App Attach + IME data ('Core' is collected implicitly when other scenarios are specified)
	.\AVD-Collect.ps1 -Profiles -MSIXAA -IME

To only run Diagnostics without collecting Core or scenario based data
	.\AVD-Collect.ps1 -DiagOnly

To store the resulting files in a different folder than C:\MSDATA
	.\AVD-Collect.ps1 -OutputDir "E:\AVDdata\"

To collect Core data and also generate a process dump for a running process, based on the process PID (e.g. in this case a process with PID = 13380)
	.\AVD-Collect.ps1 -DumpPID 13380

To start the script without the GUI (in legacy mode)
	.\AVD-Collect.ps1 -NoGUI


​​​​​​​If you are missing any of the data that the script should normally collect (see "Data being collected"), check the content of "*_AVD-Collect-Log.txt" and "*_AVD-Collect-Errors.txt" files for more information. Some data may not be present during data collection and thus not picked up by the script. This should be visible in one of the two text files.


PowerShell ExecutionPolicy
--------------------------

If the script does not start, complaining about execution restrictions, then in an elevated PowerShell console run:

	Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Scope Process

and verify with "Get-ExecutionPolicy -List" that no ExecutionPolicy with higher precedence is blocking execution of this script.
The script is digitally signed with a Microsoft Code Sign certificate.

After that run the AVD-Collect script again.


Once the script has started, p​​​lease read the "IMPORTANT NOTICE" message and confirm if you agree to continue with the data collection.

Depending on the amount of data that needs to be collected, the script may need run for up to a few minutes. Please wait until the script finishes collecting all the data.



====================
Data being collected
====================

The collected data is stored in a subfolder under C:\MSDATA\ and at the end of the data collection, the results are archived into a .zip file. No data is automatically uploaded to Microsoft.

Data collected in the "Core" scenario:

	• Log files
		o C:\Packages\Plugins\Microsoft.Azure.ActiveDirectory.AADLoginForWindows\
		o C:\Packages\Plugins\Microsoft.Compute.JsonADDomainExtension\<version>\Status\
		o C:\Packages\Plugins\Microsoft.EnterpriseCloud.Monitoring.MicrosoftMonitoringAgent\<version>\Status\
		o C:\Packages\Plugins\Microsoft.Powershell.DSC\<version>\Status\​​​​​​​
		o C:\Program Files\Microsoft RDInfra\AgentInstall.txt
		o C:\Program Files\Microsoft RDInfra\​GenevaInstall.txt
		o C:\Program Files\Microsoft RDInfra\​SXSStackInstall.txt
		o C:\Program Files\Microsoft RDInfra\WVDAgentManagerInstall.txt
		o C:\Users\AgentInstall.txt
		o C:\Users\AgentBootLoaderInstall.txt
		o C:\Windows\debug\NetSetup.log
		o C:\Windows\Temp\ScriptLog.log
		o C:\WindowsAzure\Logs\WaAppAgent.log
		o C:\WindowsAzure\Logs\MonitoringAgent.log
		o C:\WindowsAzure\Logs\Plugins\
		o C:\Program Files\Microsoft RDInfra\AVDAgentManagerInstall.txt (Windows 7 only)
	• Local group membership information
		o Remote Desktop Users
	• The content of the "C:\Users\%username%\AppData\Local\Temp\DiagOutputDir\RdClientAutoTrace" folder (available on devices used as source clients to connect to AVD hosts) from the past 5 days, containing:
		o AVD remote desktop client connection ETL traces
		o AVD remote desktop client application ETL traces
		o AVD remote desktop client upgrade log (MSI.log)
	• "Qwinsta /counter" output
	• DxDiag output in .txt format with no WHQL check
	• Geneva, Remote Desktop and Remote Assistance Scheduled Task information
	• "Azure Instance Metadata service endpoint" request info
	• Convert existing .tsf files on AVD hosts from under "C:\Windows\System32\config\systemprofile\AppData\Roaming\Microsoft\Monitoring\Tables" into .csv files and collect the resulting .csv files
	• "set MON" output (Monitoring Agent)
	• Output of "C:\Program Files\Microsoft Monitoring Agent\Agent\TestCloudConnection.exe"
	• "dsregcmd /status" output
	• AVD Services API health check (BrokerURI, BrokerURIGlobal, DiagnosticsUri, BrokerResourceIdURIGlobal)
	• Event Logs
		o Application
		o Microsoft-Windows-AAD/Operational
		o Microsoft-Windows-CAPI2/Operational
		o Microsoft-Windows-Diagnostics-Performance/Operational
		o Microsoft-Windows-DSC/Operational
		o Microsoft-Windows-PowerShell/Operational
		o Microsoft-Windows-RemoteDesktopServices
		o Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Admin
		o Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational
		o Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Admin
		o Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational
		o Microsoft-Windows-TaskScheduler/Operational
		o Microsoft-Windows-TerminalServices-LocalSessionManager/Admin
		o Microsoft-Windows-TerminalServices-LocalSessionManager/Operational
		o Microsoft-Windows-TerminalServices-PnPDevices/Admin
		o Microsoft-Windows-TerminalServices-PnPDevices/Operational
		o Microsoft-Windows-TerminalServices-RDPClient/Operational
		o Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin
		o Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational
		o Microsoft-Windows-WinINet-Config/ProxyConfigChanged
		o Microsoft-Windows-Winlogon/Operational
		o Microsoft-Windows-WinRM/Operational
		o Microsoft-WindowsAzure-Diagnostics/Bootstrapper
		o Microsoft-WindowsAzure-Diagnostics/GuestAgent
		o Microsoft-WindowsAzure-Diagnostics/Heartbeat
		o Microsoft-WindowsAzure-Diagnostics/Runtime
		o Microsoft-WindowsAzure-Status/GuestAgent
		o Microsoft-WindowsAzure-Status/Plugins
		o Security
		o Setup
		o System
	• Registry keys
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\RdClientRadc
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Remote Desktop​
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Azure\DSC
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSRDC
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Ole
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDAgentBootLoader
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDInfraAgent
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDMonitoringAgent
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AVDAgentManager (Windows 7 only)
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSLicensing
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Ole
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Terminal Server Client
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies
		o ​​​​​​​HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
		o ​​​​​​​HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server​​
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\TERMINPUT_BUS
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RdAgent
		o ​​​​​​​HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RDAgentBootLoader
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AVDAgent (Windows 7 only)
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AVDAgentManager (Windows 7 only)
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\TermService
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UmRdpService
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinRM​​
		o HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings
	• Networking information (firewall rules, ipconfig /all, network profiles, netstat -anob, proxy configuration, route table, winsock show catalog, Get-NetIPInterface, netsh interface Teredo show state)
	• Details of the running processes and services
	• List of installed software (on both machine and user level)
	• Information on installed AntiVirus products
	• List of top 10 processes using CPU at the moment when the script is running
	• "gpresult /h" and "gpresult /r /v" output
	• "fltmc filters" and "fltmc volumes" output
	• File versions of the currently running binaries
	• File versions of key binaries (Windows\System32\*.dll, Windows\System32\*.exe, Windows\System32\*.sys, Windows\System32\drivers\*.sys)
	• Basic system information
	• .NET Framework information
	• "Get-DscConfiguration" and "Get-DscConfigurationStatus" output
	• Msinfo32 output (in .nfo and .txt format)
	• PowerShell version
	• WinRM configuration information
	• "Get-Hotfix" output
	• Output of "Test-DscConfiguration -Detailed"
	• Output of "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe" (if the NVIDIA GPU drivers are already installed on the machine)
	• Certificate store information ('My' and 'AAD Token Issuer')
	• Certificate thumbprint information ('My' and 'AAD Token Issuer')
	• SPN information (WSMAN, TERMSRV)
	• "nltest /sc_query:<domain>" and "nltest /dnsgetdc:<domain>" output
	• Remote Desktop License Server database information (if RDLS role is installed - for Server OS deployments):
		o Win32_TSLicenseKeyPack under '*_RDS\*_rdls_LicenseKeyPacks.html'
		o Win32_TSIssuedLicense under '*_RDS\*_rdls_IssuedLicenses.html'
	• Tree output of the "C:\Windows\RemotePackages" and "C:\Program Files\Microsoft RDInfra" folder's content
	• MMR log from "C:\Program Files\MsRDCMMRHost\MsRDCMMRHostInstall.log"
	• "tasklist /v" output


Data collected additionally to the "Core" dataset, depending on the selected scenario or command line parameter(s) used:

When using "-Profiles" scenario/parameter:

	• Log files
		o C:\ProgramData\FSLogix\Logs
	• FSLogix tool output (frx list-redirects, frx list-rules, frx version)
	• Registry keys
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office​
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\OneDrive
		o HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Office
		o HKEY_CURRENT_USER\Volatile Environment
		o HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Exclusions
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\FSLogix	
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive
		o HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\frxccd
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\frxccds
	• Output of 'whoami /all'
	• Event Logs
		o Microsoft-FSLogix-Apps/Admin
		o Microsoft-FSLogix-Apps/Operational
		o Microsoft-FSLogix-CloudCache/Admin
		o Microsoft-FSLogix-CloudCache/Operational
		o Microsoft-Windows-GroupPolicy/Operational
		o Microsoft-Windows-SMBClient/Connectivity
		o Microsoft-Windows-SMBClient/Operational
		o Microsoft-Windows-SMBClient/Security
		o Microsoft-Windows-SMBServer/Connectivity
		o Microsoft-Windows-SMBServer/Operational
		o Microsoft-Windows-SMBServer/Security
		o Microsoft-Windows-User Profile Service/Operational
		o Microsoft-Windows-VHDMP/Operational
	• Local group membership information
		o FSLogix ODFC Exclude List
		o FSLogix ODFC Include List
		o FSLogix Profile Exclude List
		o FSLogix Profile Include List
	• DACLs for the FSLogix Profiles and ODFC storage logations


When using "-MSIXAA" scenario/parameter:

	• Event Logs
		o Microsoft-Windows-AppXDeploymentServer/Operational
		o Microsoft-Windows-RemoteDesktopServices (filtered for MSIX App Attach events only)


When using "-Teams" scenario/parameter:

	• Log files
		o %appdata%\Microsoft\Teams\logs.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_calling.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_cdl.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_cdlWorker.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_chatListData.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_sync.txt
		o %userprofile%\Downloads\MSTeams Diagnostics Log DATE_TIME_vdi_partner.txt
	• Registry keys
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RDWebRTCSvc


When using "-MSRA" scenario/parameter:

	• Local group membership information
		o Distributed COM Users
		o Offer Remote Assistance Helpers
	• Registry keys
		o HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Remote Assistance
	• Event Logs
		o Microsoft-Windows-RemoteAssistance/Admin
		o Microsoft-Windows-RemoteAssistance/Operational
	• Information on the COM Security permissions


When using "-SCard" scenario/parameter:

	• Event Logs
		o Microsoft-Windows-Kerberos-KDCProxy/Operational
		o Microsoft-Windows-SmartCard-Audit/Authentication
		o Microsoft-Windows-SmartCard-DeviceEnum/Operational
		o Microsoft-Windows-SmartCard-TPM-VCard-Module/Admin
		o Microsoft-Windows-SmartCard-TPM-VCard-Module/Operational
	• "certutil -scinfo -silent" output
	• RD Gateway information when ran on the KDC Proxy server and the RD Gateway role is present
		o Server Settings, Resource Authorization Policy, Connection Authorization Policy


When using "-IME" scenario/parameter:

	• Registry keys
		o HKEY_CURRENT_USER\Control Panel\International
		o HKEY_CURRENT_USER\Keyboard Layout
		o HKEY_CURRENT_USER\Software\AppDataLow\Software\Microsoft\IME
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\CTF
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\IME
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\IMEMIP
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\IMEJP
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Input
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputMethod
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Keyboard
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech Virtual
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore
		o HKEY_CURRENT_USER\SOFTWARE\Microsoft\Spelling
		o HKEY_LOCAL_MACHINE\SYSTEM\Keyboard Layout
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CTF
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IME
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IMEJP
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IMEKR
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IMETC
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Input
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InputMethod
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MTF
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MTFFuzzyFactors
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MTFInputType
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MTFKeyboardMappings
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore
		o HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Spelling
	• 'tree' output for the following folders:
		o %APPDATA%\Microsoft\IME
		o %APPDATA%\Microsoft\InputMethod
		o %LOCALAPPDATA%\Microsoft\IME
		o C:\Windows\System32\IME
		o C:\Windows\IME
	• 'Get-Culture' and 'Get-WinUserLanguageList' output


When using "-HCI" scenario/parameter:
	• Log files
		o %ProgramData%\AzureConnectedMachineAgent\Log\himds.log
		o %ProgramData%\AzureConnectedMachineAgent\Log\azcmagent.log



========
AVD-Diag
========

AVD-Collect also generates an overall view of the deployment and diagnostics results to quickly pinpoint several known issues, thus significantly speeding up troubleshooting.
Diagnostics may also include checks for options/features that are not available on the system. This is expected as Diagnostics aims to cover as many topics as possible in one. Always place the results into the right troubleshooting context.
New diagnostics checks may be added in each new release, so make sure to always use the latest version of the script.​​​​​​​

Important: AVD-Diag is not a replacement of a full data analysis. Depending on the scenario, further data collection and analysis may be needed.

The script can perform the following diagnostics:

	• Brief check of the system the script is running on (from AVD point of view): FQDN, OS, OS Build, OS SKU, VM Size, VM Location
		o Check if the VM is part of a AVD host pool: SessionHostPool name, Ring, Geography
		o Check if the running OS is supported when the VM is part of a AVD host pool
		o Check for out of support Windows 10 Enterprise and Windows 10 Enterprise multi-session versions
		o Check for local time/time zone
		o Check for last machine boot up time, with an extra notification if it occurred >= 25 hours ago
		o Check for the number of vCPUs available on the machine
		o Check for Remote Desktop Session Host role installation (on Server OS deployments)
		o Check for .NET Framework version
		o Check for "OOBEInProgress", "SystemSetupInProgress", "SetupPhase", "LmCompatibilityLevel", "DeleteUserAppContainersOnLogoff", "RpcAuthnLevelPrivacyEnabled", "RpcNamedPipeAuthentication", "AllowEncryptionOracle", "DisableRegistryTools", "ScreenSaverGracePeriod", "DisableLockWorkstation", "ProcessTSUserLogonAsync" registry keys
	• Check for graphics configuration
	• Check for the top 10 processes using CPU at the moment when the script is running
	• Check for total and available disk space
	• Check for various settings that are sometimes related to Black Screen logon scenarios
	• Check for User Account Control (UAC) configuration
	• Check for Azure AD-join configuration
	• Check for Domain Controller configuration (trusted and available)
	• Check for Windows Update configuration
	• Check the status of key services
	• Check for current and previous AVD Agent and Stack versions and their installation dates
	• Check for the following registry keys:
		o HKLM\SOFTWARE\Microsoft\RDInfraAgent\IsRegistered
		o HKLM\SOFTWARE\Microsoft\RDInfraAgent\RegistrationToken
	• Check for RDP and RD listeners configuration: fEnableWinStation, fReverseConnectMode, ReverseConnectionListener, fDenyTSConnections, fQueryUserConfigFromDC
	• Check for SSL/TLS configuration
	• Check for DNS configuration (Windows 10+ and Server OS)
	• Check for proxy and route configuration
	• check for Firewall configuration (Note: Firewall software available inside the VM - does not apply to external firewalls)
	• Check for Session Time Limit policy settings
	• Check for Time Zone Redirection policy configuration
	• Check for device and resource redirection policy configuration
	• Check for the Screen Capture Protection policy configuration
	• Check for RDS licensing configuration
	• Check for User Rights policy configuration (SeNetworkLogonRight, SeDenyNetworkLogonRight, SeRemoteInteractiveLogonRight, SeDenyRemoteInteractiveLogonRight)
	• Check for Windows Desktop and Microsoft Store RD client information
	• Check for FSLogix best practice settings for enterprises
	• Check for "frxsvc" service recovery settings
	• Check for FSLogix registry keys "DeleteLocalProfileWhenVHDShouldApply", "SizeInMBs", "VolumeType", "FlipFlopProfileDirectoryName", "NoProfileContainingFolder", "RedirXMLSourceFolder", "IncludeOfficeActivation", "CleanupInvalidSessions"
	• Check if the FSLogix storage location defined under 'VHDLocations' is reachable (Test-NetConnection), for Profile and Office containers
	• Check for 'CloudKerberosTicketRetrievalEnabled' and 'LoadCredKeyFromProfile' reg keys, for FSLogix (Azure AD Kerberos Auth for Azure Files)
	• Check for Cloud Cache "CCDLocations" registry key for Profile and Office Container
	• Check for the presence of the recommended Windows Defender Antivirus exclusion values when FSLogix is present on the system
	• Check if reg key "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\DisableAntiSpyware" is enabled on Server OS
	• Check for AAD Identity Provider reg key
	• Added check for Microsoft Office configuration
	• Check OneDrive configuration and requirements for FSLogix compatibility
	• Check media optimization configuration for Teams when Teams is present on the system
	• Check for the Multimedia configuration (Multimedia Redirection and Audio/Video privacy settings)
	• Check for PowerShell Language Mode and Execution Policy configuration
	• Check WinRM configuration / requirements
		o ​​​​​​​Presence of "WinRMRemoteWMIUsers__" group
		o IPv4Filter and IPv6Filter values
		o Presence of firewall rules for ports 5985 and 5986
	• Check for Services API health status (BrokerURI, BrokerURIGlobal, DiagnosticsUri, BrokerResourceIdURIGlobal)
	• Check for required URLs accesibility
	• Check for Azure Arc-enabled agent service (for Azure Stack HCI)
	• Check for secure channel connection (trust relationship) between the machine and its domain
	• Check for public IP address information (IP, City, Region, Country, Organization, Timezone)
    • Check for RDP ShortPath configuration (Windows 10+ and Server OS) for both managed and public networks
	• Check for printing configuration
	• Check for AVD agent issues over the past 5 days:
	​​​​​​​	o "INVALID_REGISTRATION_TOKEN" (Event 3277)
		o "INVALID_FORM" (Event 3277)
		o "InstallationHealthCheckFailedException" (Event 3277)
		o "ENDPOINT_NOT_FOUND" (Event 3277)
		o "NAME_ALREADY_REGISTERED" (Event 3277)
		o "InstallMsiException" (Event 3277)
		o "DownloadMsiException" (Event 3277)
		o "AgentLoadException" (Event 3277)
		o "Transport received an exception" (Event 3019)
		o "RD Gateway Url" (Event 3703)
		o "MissingMethodException" (Event 3389)
		o "BootLoader exception" (Event 3389)
		o "Unable to retrieve DefaultAgent from registry" (Event 3389)
		o "SessionHost unhealthy" (Event 0)
		o "IMDS not accessible" (Event 0)
		o "Monitoring Agent Launcher file path was NOT located" (Event 0)
		o "NOT ALL required URLs are accessible!" (Event 0)
		o "Unable to connect to the remote server" (Event 0)
		o "Unhandled status [ConnectFailure] returned for url" (Event 0)
		o "Unable to extract and validate Geneva URLs" (Event 0)
		o "System.ComponentModel.Win32Exception (0x80004005)"
		o "Unable to extract and validate Geneva URLs" (Event 0 - RemoteDesktopServices)
		o "PingHost: Could not PING url" (Event 0 - RemoteDesktopServices)
		o "Unable to locate running process" (Event 0 - RemoteDesktopServices)
	• Check for FSLogix issues over the past 5 days:
		o Warnings and Errors from the "Microsoft-FSLogix-Apps/Admin" and "Microsoft-FSLogix-Apps/Operational" event logs
		o "The Kerberos client received a KRB_AP_ERR_MODIFIED error from the server" (Event 4 - System)
		o "The disk detach may have invalidated handles" (Event 0 - RemoteDesktopServices)
		o "ErrorCode: 743" (Event 0 - RemoteDesktopServices)
	• Check for MSIX App Attach issues over the past 5 days:
		o "A certificate chain processed, but terminated in a root certificate which is not trusted by the trust provider"
		o "MountDisk:  Error occured during mount"
		o "SysNtfyLogoff: Package deregistration for MSIX app attach failed during user logoff"
		o "Failed to get the minimum OS version supported for app attach: System.AggregateException: One or more errors occurred"
		o "AppAttachStageAsync: Failed to get packages to staging"
		o "DeregisterPackages: Failed to get packages to deregister"
		o "InnerRestException: Error accessing virtual disk"
	• Check for RDP ShortPath issues over the past 5 days:
		o "UDP Handshake Timeout" (Event 135 - Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational)
		o "UdpEventErrorOnMtReqComplete" (Event 226 - Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational)
	• Check for Black Screen issues over the past 5 days:
		o "The machine wide Default Launch and Activation security descriptor is invalid" (Event 10020 - System)
		o "The Windows logon process has unexpectedly terminated" (Event 4005)
	• Check for TCP issues over the past 5 days:
		o "TCP/IP failed to establish" (Event 4227 - System)
	• Check for Process and system crashes that occurred within the last 5 days
	• Check for Process hangs that occurred within the last 5 days
	• Check for installed Citrix software
	• Check for some 3rd party components potentially running on the system, which may be relevant in various troubleshooting scenarios


The script generates a *_AVD-Diag.txt and a *_AVD-Diag.html output file with the results of the above checks. Additional output files may be generated if process crashes or AVD Agent or MSIX App Attach issues have been identified.



===========
Tool Owners
===========

Robert Klemencz @ Microsoft Customer Service and Support
Alexandru Olariu @ Microsoft Customer Service and Support

If you have any feedback about AVD-Collect or AVD-Diag, send an e-mail to AVDCollectTalk@microsoft.com

