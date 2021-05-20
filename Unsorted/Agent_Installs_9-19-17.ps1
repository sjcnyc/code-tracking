# Modified by Sean Connealy 1-19-2017
# Switched qualys imput object on case statement to a hash table, and piped output to Out-GridView for choice

Write-Host ""
Write-Host ""
Write-Host "===================================================="
Write-Host "Sony Music Agent Automation Script"
Write-Host "===================================================="
Write-Host ""
Write-Host ""

$log = "$PSScriptRoot\AgentInstall.log"
$Date = Get-Date;add-content $log "${Date}: Logging Started"
$ExitCode = 1
$ErrorActionPreference = "Stop"

#Snare Registry Merge

$Date = Get-Date;add-content $log "${Date}: Merging snare.reg"
$param = "/s $PSScriptRoot\Desktop\Agents\Snare.reg"
Try
{
    Start-Process regedit -ArgumentList $param -Wait
    $Status = "Snare.reg Imported"

    Write-host $status
    $Date = Get-Date;add-content $log "${Date}: $status"
}
Catch
{
    $status = "Snare Registry Merge Failed, $_"
    $ExitCode = 0

    Write-host $status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}

#McAfee VSE Install

$Date = Get-Date;add-content $log "${Date}: McAfee VSE Install"
$VSE = "$PSScriptRoot\McAfee Installation files\VSE\0000\Setupvse.exe"
#No parameter for Perpetual license. Not required/available per McAfee Documentation.
$param = "ProtectionType=Standard RUNONDEMANDSCANSILENTLY=True /qb!"
Try
{
    Start-Process $VSE -ArgumentList $param -Wait

    $service = Get-Service -Name McAfeeFramework
    $serviceStatus = $service.Status
    $status = "McAfee Agent Backwards Compatibility Service: $serviceStatus"
    Write-Host $status
    $Date = Get-Date;add-content $log "${Date}: $status"

    $service = Get-Service -Name McShield
    $serviceStatus = $service.Status
    $status = "McAfee McShield: $serviceStatus"
    Write-Host $status
    $Date = Get-Date;add-content $log "${Date}: $status"

    $service = Get-Service -Name McTaskManager
    $serviceStatus = $service.Status
    $status = "McAfee Task Manager: $serviceStatus"
    Write-Host $status
    $Date = Get-Date;add-content $log "${Date}: $status"

    $service = Get-Service -Name mfevtp
    $serviceStatus = $service.Status
    $status = "McAfee Validation Trust Protection Service: $serviceStatus"
    Write-host $status
    $Date = Get-Date;add-content $log "${Date}: $status"

    $Status = "McAfee VSE Installed"
    Write-host $status
    $Date = Get-Date;add-content $log "${Date}: $status"
}
Catch
{
    $status = "McAfee VSE Install Failed, $_"
    $ExitCode = 0

    Write-host $status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}

#McAfee Agent Install
$prevAgent = $null

Try
{
    $prevAgent = Get-WmiObject -Class win32_product | Where-Object Name -eq "McAfee Agent"
}
Catch
{
    $Status = "Error getting McAfee Agent version, $_"
    Write-Host $Status -ForegroundColor Red

    $Date = Get-Date;add-content $log "${Date}: $status"
    $ExitCode = 0
}
$Date = Get-Date;add-content $log "${Date}: McAfee Agent Install"
$MAgent = "$PSScriptRoot\McAfee Installation files\MA\FRAMEPKG.exe"
$param = "/INSTALL=AGENT /SILENT"
Try
{
    Start-Process $MAgent -ArgumentList $param -Wait

    $Status = "McAfee Agent Installed, Service $McAfeeAgentStatus"
    $newAgent = Get-WmiObject -Class win32_product | Where-Object Name -eq "McAfee Agent"

    $prevVer = $prevAgent.Version
    $newVer = $newAgent.Version

    if($prevVer -eq $newVer)
    {
        $ExitCode = 0
        $status = "McAfee Agent Version did not update, Prev: $prevVer, Cur: $newVer"
        Write-host $status -ForegroundColor Red
        $Date = Get-Date;add-content $log "${Date}: $status"
    }
    else
    {
        $status2 = "McAfee Agent Version: Prev: $prevVer | Cur: $newVer"
        Write-Host $Status2
        $Date = Get-Date;add-content $log "${Date}: $status2"

         Write-host $status
        $Date = Get-Date;add-content $log "${Date}: $status"
    }
}
Catch
{
    $status = "McAfee Agent Install Failed, $_"
    $ExitCode = 0

    Write-host $status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}

#Start Qualys Install
$ActivationID = $null
Do {

    $menuoptions = [ordered]@{
        "1"  = "MNET - Global - Active Directory";
        "2"  = "MNET - Global - Exchange";
        "3"  = "ME - Global - Active Directory";
        "4"  = "ME - Global - DMM";
        "5"  = "ME - Global - Exchange";
        "6"  = "ME - Global - WSUS (Tier 0)";
        "7"  = "ME - Global - PKI";
        "8"  = "ME - US - Lansweeper";
        "9"  = "ME - US ManageEngine";
        "10" = "ME - US - Steelcase";
        "11" = "ME - US - Jumpbox Servers";
        "12" = "ME - US - Backup Servers";
        "13" = "ME - US - SQL Servers";
        "14" = "ME - US - NPS Servers";
        "15" = "WW - Veeam";
        "16" = "IO - Argentina - Local Server";
        "17" = "IO - Australia - Local Server";
        "18" = "IO - Austria - Local Server";
        "19" = "IO - Beijing - Local Server";
        "20" = "IO - Belgium - Local Server";
        "21" = "IO - Berlin - Local Server";
        "22" = "IO - Brazil - Local Server";
        "23" = "IO - Canada - Local Server";
        "24" = "IO - Chile - Local Server";
        "25" = "IO - Colombia - Local Server";
        "26" = "IO - Costa Rica - Local Server";
        "27" = "IO - Czech Republic - Local Server";
        "28" = "IO - Denmark - Local Server";
        "29" = "IO - Finland - Local Server";
        "30" = "IO - France - Local Server";
        "31" = "IO - Greece - Local Server";
        "32" = "IO - Hong Kong - Local Server";
        "33" = "IO - Hungary - Local Server";
        "34" = "IO - India - Local Server";
        "35" = "IO - Indonesia - Local Server";
        "36" = "IO - Ireland - Local Server";
        "37" = "IO - Italy - Local Server";
        "38" = "IO - Malaysia - Local Server";
        "39" = "IO - Mexico - Local Server";
        "40" = "IO - Miami - Local Server";
        "41" = "IO - Munich - Local Server";
        "42" = "IO - Netherlands - Local Server";
        "43" = "IO - New Zealand - Local Server";
        "44" = "IO - Norway - Local Server";
        "45" = "IO - Poland - Local Server";
        "46" = "IO - Portugal - Local Server";
        "47" = "IO - Puerto Rico - Local Server";
        "48" = "IO - Russia - Local Server";
        "49" = "IO - Shanghai - Local Server";
        "50" = "IO - Singapore - Local Server";
        "51" = "IO - South Africa - Local Server";
        "52" = "IO - South Korea - Local Server";
        "53" = "IO - Spain (Barcelona) - Local Server";
        "54" = "IO - Spain (Madrid) - Local Server";
        "55" = "IO - Sweden - Local Server";
        "56" = "IO - Switzerland - Local Server";
        "57" = "IO - Taiwan - Local Server";
        "58" = "IO - The Orchard - Local Server";
        "59" = "IO - Turkey - Local Server";
        "60" = "IO - UK - Local Server";
        "61" = "IO - US 25 Madison - Local Server";
        "62" = "IO - US Boyers - Local Server";
        "63" = "IO - US Culver City - Local Server";
        "64" = "IO - US Culpeper - Local Server";
        "65" = "IO - US Edina - Local Server";
        "66" = "IO - US Nashiville - Local Server";
        "67" = "IO - US Red NY - Local Server";
        "68" = "IO - US Rutherford - Local Server";
        "69" = "IO - US San Fran - Local Server";
        "70" = "IO - US Vorhees - Local Server";
        "71" = "IO - US W 44th-NYC - Local Server";
        "72" = "IO - US Venezuela - Local Server";
        "73" = "Exit";
    }

    $reportsmenu = $menuoptions | Out-GridView -Title "Please Select your Qualys Activation" -OutputMode Single

    switch ($ReportsMenu.Name) {
        1 #MNET - Global - Active Directory
        {ActivationID = 'a1c30e48-349b-4a2a-87a9-da176780067d'}
        2 #MNET - Global - Exchange
        {ActivationID = 'aed34daa-e1b1-4c44-bbc5-9686642a4e37'}
        3 #ME - Global - Active Directory
        {$ActivationID = '938b5752-95ba-477c-a391-c6bb2adc717c'}
        4 #ME - Global - DMM
        {$ActivationID = '25773c06-3a87-4760-854d-fd5ec6c39dac'}
        5 #ME - Global - Exchange
        {$ActivationID = '77ea11d8-ffaf-49c8-85f3-2049a5e08e44'}
        6 #ME - Global - WSUS
        {$ActivationID = '120f083c-c604-443c-a080-36258e71ea42'}
        7 #ME - Global - PKI
        {$ActivationID = '68e81281-1e56-4d0a-8276-d8a0b8cde68d'}
        8 #ME - US - Lansweeper
        {$ActivationID = 'e6df114e-bd53-480c-b61a-03bd6464221d'}
        9 #ME - US - ManageEngine
        {$ActivationID = 'a9a98ce1-27b1-4c6f-8852-31fd6031cc19'}
        10 #ME - US - Steelcase
        {$ActivationID = '2be65451-33dd-4bfe-882e-99761e524343'}
        11 #ME - US - Jumpbox Servers
        {$ActivationID = '77ea11d8-ffaf-49c8-85f3-2049a5e08e44'}
        12 #ME - US - Backup Servers
        {$ActivationID = '55b9e47e-d2d2-4145-be43-d75dfaad517b'}
        13 #ME - US - SQL Servers
        {$ActivationID = 'e1e861fc-7701-4cdc-96b3-c190bdf5a5a1'}
        14 #ME - US - NPS Servers
        {$ActivationID = '2cbb73e3-8cb8-45b6-9299-a06807df46cf'}
        15 #WW - Veeam
        {$ActivationID = 'ec1fd2ea-4af4-4245-aa15-538193d40614'}
        16 #IO - Argentina - Local Servers
        {$ActivationID = '5d7c9d31-e9e2-4f9a-bda8-0cf8e53d7c3e'}
        17 #IO - Australia - Local Servers
        {$ActivationID = '934ae98a-7580-403a-8733-6bb966680613'}
        18 #IO - Austria - Local Servers
        {$ActivationID = 'fa15ba68-fa90-46db-9977-949f4d85bc00'}
        19 #IO - Beijing - Local Servers
        {$ActivationID = 'ea44961d-2f1a-4c1a-b75c-ba50cf5813de'}
        20 #IO - Belgium - Local Servers
        {$ActivationID = 'bfe7615d-ba13-4579-bf99-4c7b85756f3c'}
        21 #IO - Berlin - Local Servers
        {$ActivationID = '7e707c80-aafc-440e-9040-62712cb64796'}
        22 #IO - Brazil - Local Servers
        {$ActivationID = '5c305e5d-28af-4928-bff9-6402db9599b2'}
        23 #IO - Canada - Local Servers
        {$ActivationID = '8c90209b-33cd-49a0-8798-af64dde7a289'}
        24 #IO - Chile - Local Servers
        {$ActivationID = 'd2ebcdd3-8284-4293-8689-ef1edbd11c6c'}
        25 #IO - Colombia - Local Servers
        {$ActivationID = 'dfb1e71a-0c25-494e-9530-7f944ea3b4ab'}
        26 #IO - Costa Rica - Local Servers
        {$ActivationID = '947e61db-b80a-4736-9238-f83a182c43a7'}
        27 #IO - Czech Republic - Local Servers
        {$ActivationID = '5cf8a4e2-bcb0-4e4a-adfb-30487d6b3b71'}
        28 #IO - Denmark - Local Servers
        {$ActivationID = 'fa6d3950-8af0-4f4a-b609-711bc485296f'}
        29 #IO - Finland - Local Servers
        {$ActivationID = 'c887a3d4-b1b2-4738-b77c-8ca85d7a148a'}
        30 #IO - France - Local Servers
        {$ActivationID = '80e1224c-439d-4780-9679-b430fd86b0a2'}
        31 #IO - Greece - Local Servers
        {$ActivationID = '98a6c5f6-0eaa-4cac-9666-20082e2edf47'}
        32 #IO - Hong Kong - Local Servers
        {$ActivationID = 'a092503b-4c29-46e2-949f-a5c4ad84d942'}
        33 #IO - Hungary - Local Servers
        {$ActivationID = 'd50351f7-4dbe-431a-a864-b712fd41a5ff'}
        34 #IO - India - Local Servers
        {$ActivationID = '762c904a-213a-4a67-be80-51ff6ed58feb'}
        35 #IO - Indonesia - Local Servers
        {$ActivationID = 'c286ca89-efd5-49e3-84a9-fa956ca53ef5'}
        36 #IO - Ireland - Local Servers
        {$ActivationID = '2c158636-1645-4ae2-910b-7c217c2a10bd'}
        37 #IO - Italy - Local Servers
        {$ActivationID = 'debe71d6-f9aa-4271-ac70-a90957b67fd9'}
        38 #IO - Malaysia - Local Servers
        {$ActivationID = '2a5dbd30-2170-4cbe-9e66-2e1230582520'}
        39 #IO - Mexico - Local Servers
        {$ActivationID = '2b978c01-89fb-49a1-ab96-71477eda449d'}
        40 #IO - Miami - Local Servers
        {$ActivationID = '96e1f5b-81a5-420c-b918-2458f0443ffe'}
        41 #IO - Munich - Local Servers
        {$ActivationID = '0609f09f-018c-458e-832f-6fc4c7f3f096'}
        42 #IO - Netherlands - Local Servers
        {$ActivationID = 'e5917141-458c-4417-b824-865a7f19c344'}
        43 #IO - New Zealand - Local Servers
        {$ActivationID = 'e4e91085-6875-4ed2-80b3-5b07b93463ee'}
        44 #IO - Norway - Local Servers
        {$ActivationID = '7d79f2f2-4763-4510-a24a-c9535183f4e6'}
        45 #IO - Poland - Local Servers
        {$ActivationID = '4e4c3a72-b5d3-4c23-ae89-4feca4a0bf68'}
        46 #IO - Portugal - Local Servers
        {$ActivationID = '513cbde3-3323-41cb-b19b-32cf831c1550'}
        47 #IO - Puerto Rico - Local Servers
        {$ActivationID = '0a60e65d-0d31-4786-b83e-d652faaeb319'}
        48 #IO - Russia - Local Servers
        {$ActivationID = 'fc4440a6-ff2a-4c06-9374-b955f46b7d94'}
        49 #IO - Shanghai - Local Servers
        {$ActivationID = '075003e1-2564-4274-aaa6-a3d76f0ef754'}
        50 #IO - Singapore - Local Servers
        {$ActivationID = 'ba308f25-6fe0-4873-a51b-c4bf206fae16'}
        51 #IO - South Africa - Local Servers
        {$ActivationID = 'e73f6a03-49b1-4bb7-8b4e-88212749915b'}
        52 #IO - South Korea - Local Servers
        {$ActivationID = '8f5c6624-b861-469c-9560-82d0102b1d01'}
        53 #IO - Spain (Barcelona) - Local Servers
        {$ActivationID = '24b9ad19-dc09-449d-9bf0-ef4bd2508668'}
        54 #IO - Spain (Madrid) - Local Servers
        {$ActivationID = 'e37ce0b4-1360-432a-8b07-d97fc27274bb'}
        55 #IO - Sweden - Local Servers
        {$ActivationID = '21de7a3f-9f40-43e7-8384-c0cc85c722a9'}
        56 #IO - Switzerland - Local Servers
        {$ActivationID = 'c3f77802-f47d-4f6f-9d32-58d153ddf78f'}
        57 #IO - Taiwan - Local Servers
        {$ActivationID = '8c97dc07-10d2-4079-b207-f14679688632'}
        58 #IO - The Orchard - Local Servers
        {$ActivationID = '60abec31-3183-4e33-884d-be2571b8ad98'}
        59 #IO - Turkey - Local Servers
        {$ActivationID = '74d04354-1588-4b7a-a927-bbc5cae87c7c'}
        60 #IO - UK - Local Servers
        {$ActivationID = '1f78da19-09f6-489b-849e-e0bfad95fabc'}
        61 #IO - US 25 Madison - Local Servers
        {$ActivationID = 'd4982502-1709-446f-9462-3481f3df3456'}
        62 #IO - US Boyers - Local Servers
        {$ActivationID = '2a3ae302-36fb-4b83-b160-15b8e40ad58f'}
        63 #IO - US Culver City - Local Servers
        {$ActivationID = '798e1f1f-5968-44fe-9992-3774370b472d'}
        64 #IO - US Culpeper - Local Servers
        {$ActivationID = 'df207ca9-cf90-472c-9c5c-237529f94764'}
        65 #IO - US Edina - Local Servers
        {$ActivationID = '1f029cb7-d7b6-43ad-936a-843a3bc0a3e4'}
        66 #IO - US Nashville - Local Servers
        {$ActivationID = '71302d75-5ea6-419c-95cf-d334b9e1fe43'}
        67 #IO - US Red NY - Local Servers
        {$ActivationID = '5ce5d081-8952-49b8-bd13-0e2c30e05b63'}
        68 #IO - US Rutherford - Local Servers
        {$ActivationID = '42d7754d-841b-4670-a85c-32ccfc2ac889'}
        69 #IO - US San Fran - Local Servers
        {$ActivationID = 'cc7e031a-089f-4286-8be8-1b1b34d1e32d'}
        70 #IO - US Vorhees - Local Servers
        {$ActivationID = 'd0e759be-332c-4216-9961-5acda97651ae'}
        71 #IO - US W 44th-NYC - Local Servers
        {$ActivationID = '17ba5f46-b3d1-4d29-9394-0dbbe92282ea'}
        72 #IO - Venezuela - Local Servers
        {$ActivationID = 'a7aa3f2d-8d37-4d53-a87f-4fce264b1e66'}
        73 {Exit; exit}
        default {$errout = "Error, try again........Try 1-72 only"}
    }
}
until ($ReportsMenu -ne "")

$Qualys = "$PSScriptRoot\Qualys\QualysCloudAgent\QualysCloudAgent.exe"
$param = "CustomerId={a50a5e75-d4e1-626d-e040-10ac13047f7b} ActivationId={$ActivationID}"
$task = "Activating Qualys with $param"
$status = $null

Write-Host $Task
$Date = Get-Date;add-content $log "${Date}: $Task"

Try
{
    Start-Process $Qualys -ArgumentList $param -Wait
}
Catch
{
    $status = "Install Failed, $_"
    Write-Host $status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
    $ExitCode = 0
}
#Verify Service Installed
Try
{
    $Qualys = Get-Service -Name "Qualys Cloud Agent"
    $QualysStatus = $Qualys.Status
    $Status = "Qualys Service Installed, Service $QualysStatus"

    Write-Host $Status
    $Date = Get-Date;add-content $log "${Date}: $status"
}
    Catch
{
    $Status = "Install Failed, $_"
    $ExitCode = 0

    Write-Host $Status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}

#FireEye Install

$Date = Get-Date;add-content $log "${Date}: FireEye Install"
$param = "/i `"$PSScriptRoot\FireEye\xagtSetup_21.33.0_universal.msi`" DISGUISE=1 /qb!"

Try
{
    Start-Process msiexec -ArgumentList $param -Wait

    $service = Get-Service -Name "xagt"

    $serviceStatus = $service.Status
    $Status = "FireEye Installed, Service $serviceStatus"

    Write-host $status
    $Date = Get-Date;add-content $log "${Date}: $status"
}
Catch
{
    $status = "FireEye Install Failed, $_"
    $ExitCode = 0

    Write-host $status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}

If($ExitCode -eq 0)
{
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Agent Install Completed with Warnings",0,"Warning",48)
    $Status = "Agent Installs Completed with Warnings!"
    Write-host $Status -ForegroundColor Red
    $Date = Get-Date;add-content $log "${Date}: $status"
}
Else
{
    $status = "Agent Installs Completed Succesfully!"
    Write-host $status
    $Date = Get-Date;add-content $log "${Date}: $status"
}