
#Best Regards,
#Rasmus Røssum
#Has To Run As Administrator...
#Thank You:
#
function Ensure-IsAdministrative { If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(` [Security.Principal.WindowsBuiltInRole] “Administrator”)) { Read-Host -Prompt 'Please run the sricpt as administartor...' BREAK } }

#We Have To Have Virtualization Enabled..
$systeminfo = systeminfo $systeminfo | ForEach-Object { if ($_ -match 'virtualization') { $VirtualizationEnabled = $true } }

#Throw An Error And Stop The Script If It Is Disabled..
if (!$VirtualizationEnabled) { Write-Warning 'Virtualization should be enabled. If you see it as enabled, try the following: disable, reboot, enable, reboot..' Write-Warning 'You can find it by pressing F2 or F10, when the machine just powers on. Google how to enable for your BIOS. Can also be called VT-x' break }

#Check If VBox Is Installed..
try { Get-Command VBoxManage -ErrorAction Stop }catch {
  # Download and install OracleVBox # Prepare OutFile-Path $vboxexe = $env:temp + '\' $vboxexe = Resolve-Path $vboxexe $vboxexe = $vboxexe -as [string] $vboxexe = $vboxexe + [GUID]::NewGuid().guid + '.exe'

  # Get VirtualBox DownloadLink
  $vboxexeDL = Invoke-WebRequest -Uri 'https://www.virtualbox.org/wiki/Downloads' -UseBasicParsing
  $vboxexeDL = $vboxexeDL.Links.Href -like '*-Win.EXE'
  $vboxexeDL = $vboxexeDL -as [string]
  $vboxexeDL = [uri]$vboxexeDL

  # Download VirtualBox
  Invoke-WebRequest -Uri $vboxexeDL -OutFile $vboxexe

  # Install VirtualBox
  Start-Process $vboxexe -ArgumentList '--silent' -Wait
}

Ensure-IsAdministrative

#Add This To Be Able To Use VBoxManage, Select -Unique If It Was Already Installed..
$env:path = (($env:path -split '; ') + ($env:ProgramFiles + '\Oracle\VirtualBox') | Select-Object -Unique) -join '; '

#This Will Be The Random Name Of The New VBox
$vmName = ((New-Guid).Guid).split('- ')[0]

#This Will Be The Local Hostname
$vmNameLocal = $vmName + '.local'

#This Is Where The VM Is Located..
$vmPath = "$home\VirtualBox VMs\$vmName"

#This Will Be The Username And Password Creation..
$userName = 'Administrator'
$password = 'secretPassword'

#Size Of The Machine In MB.. Minimum Is..:
#Https://Docs.Microsoft.Com/En-Us/Windows-Server/Get-Started-19/Sys-Reqs-19
$memory = 2048
$hardisk = 32768

#Check And Download The ISO-File..
$ISODownload = 'https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVERESSENTIALS_OEM_x64FRE_en-us_1.iso'
$WebClient = New-Object System.Net.WebClient

#Thank You:
#Https://Social.Technet.Microsoft.Com/Forums/Office/En-US/E554edf7-3640-4b05-A78b-778e86070bb6/File-Exists-On-Internet?Forum=Winserverpowershell
try { $WebClient.OpenRead($ISODownload) | Out-Null Write-Output 'File Exists' } catch { Write-Output 'Error / Not Found' breaK }

#Not Working
#17763.737.190906-2324.Rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-Us_1.Iso
#Windows_Server_2016_Datacenter_EVAL_en-Us_14393_refresh.ISO
#Working
#17763.737.190906-2324.Rs5_release_svc_refresh_SERVERESSENTIALS_OEM_x64FRE_en-Us_1.Iso
#SW_DVD9_Win_Server_STD_CORE_2019_1809.2_64Bit_English_DC_STD_MLF_X22-18452.ISO
$ISOFile = Split-Path $ISODownload -Leaf $ISOFile = $env:homedrive + '\Users\' + $env:USERNAME + '\Downloads\' + $ISOFile

#Please Enter Your Domain (I Only Tried .Local)
$domainName = 'RAR.local'

#Get An Adapter Which Is Online
$Adapter = (Get-NetAdapter | Where-Object { $.Status -EQ 'UP' -and $.ConnectorPresent -EQ 'True' }).InterfaceDescription

#Make Some Credentials On The Fly
$secStringPassword = [securestring](ConvertTo-SecureString $password -AsPlainText -Force)
$credOject = [pscredential](New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword))
$SafeModeAdministratorPassword = [securestring](ConvertTo-SecureString (New-Guid | Tee-Object -Variable SafePass).Guid -AsPlainText -Force)

#Download The ISO If It Isn't Located.. At: $ISOFile
if (!(Test-Path $ISOFile)) { Invoke-WebRequest -Uri $ISODownload -OutFile $ISOFile }

#Detect The TypeID
$detection = VBoxManage unattended detect --iso=$ISOFile $typeId = ($detection -match 'TypeID').split('=').trim()[1]

#Enter The TypeID
VBoxManage createvm --name $vmName --ostype $typeId --register

#Create The VM-Harddrive
VBoxManage createmedium --filename $vmPath\hard-drive.vdi --size $hardisk

#Create The SATA-Controller, Please Contact Me If It Isn't Working, Maybe It Is Because I Have Intel..
VBoxManage storagectl $vmName --name 'SATA Controller' --add sata --controller IntelAHCI

#Attach The New Harddrive
VBoxManage storageattach $vmName --storagectl 'SATA Controller' --port 0 --device 0 --type hdd --medium $vmPath/hard-drive.vdi

#Turn I/O APIC On
VBoxManage modifyvm $vmName --ioapic on

#Define The Memory
VBoxManage modifyvm $vmName --memory $memory --vram 128

#Define The Graphics
VBoxManage modifyvm $vmName --graphicscontroller vboxsvga

<# Adjust the boot-order (thought this had something to do with the error-ISO's..) VBoxManage modifyvm $vmname --boot1 dvd VBoxManage modifyvm $vmname --boot2 disk VBoxManage modifyvm $vmname --boot3 none VBoxManage modifyvm $vmname --boot4 none #>

#Prepare The Installation And Tell VBOX To Tell Us When It Is Done..
VBoxManage unattended install $vmName --iso=$ISOFile --user=$userName --password=$password --full-user-name=$userName --install-additions --locale=da_DK --country=DK --time-zone=CET ` --post-install-command='VBoxControl guestproperty set installation_finished y'

#Remove Some OracleVBOX-Thingies
VBoxManage setextradata $vmName GUI/RestrictedRuntimeMenus ALL

Start-Process The VM And Installation, Remove ' --Type Headless' If You Would Like It To Pop-Up, Else Go To Oracle VBOX And Click The VM And Click 'Show'
VBoxManage startvm $vmName --type headless

#Wait For The Installation To Become Done..
VBoxManage guestproperty wait $vmName installation_finished

#Add The New VM To TrustedHosts (Maybe I Should Add Previous Machines Too..)
Start-Service WinRM Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $vmNameLocal -Force

#dd And Enable The Network
VBoxManage controlvm $vmName nic1 bridged $Adapter VBoxManage controlvm $vmName setlinkstate1 on

#Wait For The WSManagement To Be Ready..
$Connected = 0
while (!$Connected) { try { Test-WSMan $vmNameLocal $Connected = $true }catch { $Connected = $false } } Clear-Variable Connected

#Install The Active Directory On The Machine
Invoke-Command -ComputerName $vmNameLocal -Credential $credOject -ScriptBlock { 'DomainName: ' + $Using:domainName
  Install-WindowsFeature -Name AD-Domain-Services
  Import-Module ADDSDeployment
  Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "default" -DomainName $Using:domainName -ForestMode "default" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword $Using:SafeModeAdministratorPassword ` -Force:$true

  function Set-NewWinUserLanguage($LanguageTag) {
    $LanguageList = Get-WinUserLanguageList

    $OldLanguageList = $LanguageList.LanguageTag

    $LanguageList.Clear()
    $LanguageList.Add($LanguageTag)

    foreach ($Language in $OldLanguageList) {
      $LanguageList.Add($Language)
    }

    Set-WinUserLanguageList $LanguageList -Force
  }

  # Set the keyboard-layout.
  # Find your language here:
  # https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows#language-interface-packs-lips
  # I'm a dane, so this is what i would do..
  # Function by me, to add new keyboard language..
  Set-NewWinUserLanguage -LanguageTag 'da-DK'
}