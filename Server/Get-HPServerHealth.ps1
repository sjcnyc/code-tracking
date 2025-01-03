function Get-HPServerHealth
{
    <#
    .SYNOPSIS
       Get HP server hardware health status information from WBEM wmi providers.
    .DESCRIPTION
       Get HP server hardware health status information from WBEM wmi providers. Results returned are the overall
       health status of the server by default. Optionally further health information about several individual
       components can be queries and returned as well.
    .PARAMETER ComputerName
       Specifies the target computer or computers for data query.
    .PARAMETER IncludePSUHealth
        Include power supply health results
    .PARAMETER IncludeTempSensors
        Include temperature sensor results
    .PARAMETER IncludeEthernetTeamHealth
        Include ethernet team health results
    .PARAMETER IncludeFanHealth
        Include fan health results
    .PARAMETER IncludeEthernetHealth
       Include ethernet adapter health results
    .PARAMETER IncludeHBAHealth
        Include HBA health results
    .PARAMETER IncludeArrayControllerHealth
       Include array controller health results
    .PARAMETER ThrottleLimit
       Specifies the maximum number of systems to inventory simultaneously 
    .PARAMETER Timeout
       Specifies the maximum time in second command can run in background before terminating this thread.
    .PARAMETER ShowProgress
       Show progress bar information
    .PARAMETER PromptForCredential
       Prompt for remote system credential prior to processing request.
    .PARAMETER Credential
       Accept alternate credential (ignored if the localhost is processed)
    .EXAMPLE
       PS> $cred = get-credential
       PS> Get-HPServerHealth -ComputerName 'TestServer' -Credential $cred
       
            ComputerName                       Manufacturer           HealthState
            ------------                       ------------           -----------
            TestServer                         HP                     OK       
            
       Description
       -----------
       Attempts to retrieve overall health status of TestServer.

    .EXAMPLE
       PS> $cred = get-credential
       PS> $c = Get-HPServerhealth -ComputerName 'TestServer' -Credential $cred 
                                   -IncludeEthernetTeamHealth 
                                   -IncludeArrayControllerHealth 
                                   -IncludeEthernetHealth 
                                   -IncludeFanHealth 
                                   -IncludeHBAHealth 
                                   -IncludePSUHealth 
                                   -IncludeTempSensors
        
       PS> $c._TempSensors | select Name, Description, PercentToCritical

        Name                         Description                                                   PercentToCritical
        ----                         -----------                                                   -----------------
        Temperature Sensor 1         Temperature Sensor 1 detects for Ambient / External /...                  41.46
        Temperature Sensor 2         Temperature Sensor 2 detects for CPU board                                48.78
        Temperature Sensor 3         Temperature Sensor 3 detects for CPU board                                48.78
        Temperature Sensor 4         Temperature Sensor 4 detects for Memory board                             29.89
        Temperature Sensor 5         Temperature Sensor 5 detects for Memory board                             28.74
        Temperature Sensor 6         Temperature Sensor 6 detects for Memory board                             32.18
        Temperature Sensor 7         Temperature Sensor 7 detects for Memory board                             33.33
        Temperature Sensor 8         Temperature Sensor 8 detects for Power Supply Bays                        42.22
        Temperature Sensor 9         Temperature Sensor 9 detects for Power Supply Bays                        47.69
        Temperature Sensor 10        Temperature Sensor 10 detects for System board                            46.67
        Temperature Sensor 11        Temperature Sensor 11 detects for System board                            38.57
        Temperature Sensor 12        Temperature Sensor 12 detects for System board                            41.11
        Temperature Sensor 13        Temperature Sensor 13 detects for I/O board                               41.43
        Temperature Sensor 14        Temperature Sensor 14 detects for I/O board                               48.57
        Temperature Sensor 15        Temperature Sensor 15 detects for I/O board                               44.29
        Temperature Sensor 19        Temperature Sensor 19 detects for System board                               30
        Temperature Sensor 20        Temperature Sensor 20 detects for System board                            38.57
        Temperature Sensor 21        Temperature Sensor 21 detects for System board                            33.75
        Temperature Sensor 22        Temperature Sensor 22 detects for System board                            33.75
        Temperature Sensor 23        Temperature Sensor 23 detects for System board                            45.45
        Temperature Sensor 24        Temperature Sensor 24 detects for System board                               40
        Temperature Sensor 25        Temperature Sensor 25 detects for System board                               40
        Temperature Sensor 26        Temperature Sensor 26 detects for System board                               40
        Temperature Sensor 29        Temperature Sensor 29 detects for Storage bays                            58.33
        Temperature Sensor 30        Temperature Sensor 30 detects for System board                            60.91
       Description
       -----------
       Gathers all HP health information about TestServer using an alternate credential. Displays the temperature
       sensor information.

    .NOTES
       For obvious reasons, you will need to have the HP WBEM software installed on the server.
       
       WBEM Provider Download:
       http://h18004.www1.hp.com/products/servers/management/wbem/providerdownloads.html
       
       If you are troubleshooting this function your best bet is to use the hidden verbose option 
       when calling the function. This will display information within each runspace at appropriate intervals.
       
       Version History
       1.0.0 - 8/22/2013
        - Initial Release
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0,
                   HelpMessage='Computer or array of computer names to process')]
        [ValidateNotNullOrEmpty()]
        [Alias('DNSHostName','PSComputerName')]
        [string[]]
        $ComputerName=$env:computername,
        
        [Parameter(HelpMessage='Include power supply health results')]
        [switch]
        $IncludePSUHealth,
  
        [Parameter(HelpMessage='Include temperature sensor results')]
        [switch]
        $IncludeTempSensors,
 
        [Parameter(HelpMessage='Include ethernet team health results')]
        [switch]
        $IncludeEthernetTeamHealth,

        [Parameter(HelpMessage='Include fan health results')]
        [switch]
        $IncludeFanHealth,

        [Parameter(HelpMessage='Include ethernet adapter health results')]
        [switch]
        $IncludeEthernetHealth,
        
        [Parameter(HelpMessage='Include HBA health results')]
        [switch]
        $IncludeHBAHealth,
        
        [Parameter(HelpMessage='Include array controller health results')]
        [switch]
        $IncludeArrayControllerHealth,
       
        [Parameter(HelpMessage='Maximum amount of runspaces')]
        [ValidateRange(1,65535)]
        [int32]
        $ThrottleLimit = 32,
 
        [Parameter(HelpMessage='Timeout in seconds for each runspace before it gives up')]
        [ValidateRange(1,65535)]
        [int32]
        $Timeout = 120,
 
        [Parameter(HelpMessage='Display visual progress bar')]
        [switch]
        $ShowProgress,
        
        [Parameter(HelpMessage='Prompt for alternate credentials')]
        [switch]
        $PromptForCredential,
        
        [Parameter()]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    BEGIN
    {
        # Gather possible local host names and IPs to prevent credential utilization in some cases
        Write-Verbose -Message 'Creating local hostname list'
        $IPAddresses = [net.dns]::GetHostAddresses($env:COMPUTERNAME) | Select-Object -ExpandProperty IpAddressToString
        $HostNames = $IPAddresses | ForEach-Object {
            try {
                [net.dns]::GetHostByAddress($_)
            } catch {
                # We do not care about errors here...
            }
        } | Select-Object -ExpandProperty HostName -Unique
        $LocalHost = @('', '.', 'localhost', $env:COMPUTERNAME, '::1', '127.0.0.1') + $IPAddresses + $HostNames
 
        Write-Verbose -Message 'Creating initial variables'
        $runspacetimers       = [HashTable]::Synchronized(@{})
        $runspaces            = New-Object -TypeName System.Collections.ArrayList
        $bgRunspaceCounter    = 0
        
        if ($PromptForCredential)
        {
            $Credential = Get-Credential
        }
        
        Write-Verbose -Message 'Creating Initial Session State'
        $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($ExternalVariable in ('runspacetimers', 'Credential', 'LocalHost'))
        {
            Write-Verbose -Message "Adding variable $ExternalVariable to initial session state"
            $iss.Variables.Add((New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $ExternalVariable, (Get-Variable -Name $ExternalVariable -ValueOnly), ''))
        }
        
        Write-Verbose -Message 'Creating runspace pool'
        $rp = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $ThrottleLimit, $iss, $Host)
        $rp.Open()
 
        # This is the actual code called for each computer
        Write-Verbose -Message 'Defining background runspaces scriptblock'
        $ScriptBlock = {
            [CmdletBinding()]
            Param
            (
                [Parameter(Position=0)]
                [string]
                $ComputerName,
 
                [Parameter(Position=1)]
                [int]
                $bgRunspaceID,
                
                [Parameter()]
                [switch]
                $IncludePSUHealth,
          
                [Parameter()]
                [switch]
                $IncludeTempSensors,
         
                [Parameter()]
                [switch]
                $IncludeEthernetTeamHealth,

                [Parameter()]
                [switch]
                $IncludeFanHealth,
 
                [Parameter()]
                [switch]
                $IncludeEthernetHealth,
                
                [Parameter()]
                [switch]
                $IncludeHBAHealth,
                
                [Parameter()]
                [switch]
                $IncludeArrayControllerHealth
            )
            $runspacetimers.$bgRunspaceID = Get-Date
            
            try
            {
                Write-Verbose -Message ('Runspace {0}: Start' -f $ComputerName)
                $WMIHast = @{
                    ComputerName = $ComputerName
                    ErrorAction = 'Stop'
                }
                if (($LocalHost -notcontains $ComputerName) -and ($Credential -ne $null))
                {
                    $WMIHast.Credential = $Credential
                }

                #region Lookup arrays
                $BatteryStatus=@{
                    '1'='OK'
                    '2'='Degraded'
                    }
                $OperationalStatus=@{
                    '0'='Unknown'
                    '2'='OK'
                    '3'='Degraded'
                    '6'='Error'
                    } 
                $HealthStatus=@{
                    '0'='Unknown'
                    '5'='OK'
                    '10'='Degraded'
                    '15'='Minor'
                    '20'='Major'
                    '25'='Critical'
                    '30'='Non-Recoverable'
                    }
                $TeamStatus=@{
                    '0'='Unknown'
                    '2'='OK'
                    '3'='Degraded'
                    '4'='Redundancy Lost'
                    '5'='Overall Failure'
                    }
                $FanRemovalConditions=@{
                    '3'='Removable when off'
                    '4'='Removable when on or off'
                    }
                $EthernetPortType = @{
                    '0' =   'Unknown'
                    '1' =   'Other'
                    '50' =  '10BaseT'
                    '51' =  '10-100BaseT'
                    '52' =  '100BaseT'
                    '53' =  '1000BaseT'
                    '54' =  '2500BaseT'
                    '55' =  '10GBaseT'
                    '56' =  '10GBase-CX4'
                    '100' = '100Base-FX'
                    '101' = '100Base-SX'
                    '102' = '1000Base-SX'
                    '103' = '1000Base-LX'
                    '104' = '1000Base-CX'
                    '105' = '10GBase-SR'
                    '106' = '10GBase-SW'
                    '107' = '10GBase-LX4'
                    '108' = '10GBase-LR'
                    '109' = '10GBase-LW'
                    '110' = '10GBase-ER'
                    '111' = '10GBase-EW'
                }
                # Get this definition from hp_sensor.mof
                $PSUType = @('Unknown','Other','System board','Host System board','I/O board','CPU board', `
                             'Memory board','Storage bays','Removable Media Bays','Power Supply Bays', `
                             'Ambient / External / Room','Chassis','Bridge Card','Management board',`
                             'Remote Management Card','Generic Backplane','Infrastructure Network', `
                             'Blade Slot in Chassis/Infrastructure','Compute Cabinet Bulk Power Supply',`
                             'Compute Cabinet System Backplane Power Supply',`
                             'Compute Cabinet I/O chassis enclosure Power Supply',`
                             'Compute Cabinet AC Input Line','I/O Expansion Cabinet Bulk Power Supply',`
                             'I/O Expansion Cabinet System Backplane Power Supply',`
                             'I/O Expansion Cabinet I/O chassis enclosure Power Supply',
                             'I/O Expansion Cabinet AC Input Line','Peripheral Bay','Device Bay','Switch')
                $SensorType = @('Unknown','Other','System board','Host System board','I/O board','CPU board',`
                                'Memory board','Storage bays','Removable Media Bays','Power Supply Bays',`
                                'Ambient / External / Room','Chassis','Bridge Card','Management board',`
                                'Remote Management Card','Generic Backplane','Infrastructure Network',`
                                'Blade Slot in Chassis/Infrastructure','Front Panel','Back Panel','IO Bus',`
                                'Peripheral Bay','Device Bay','Switch','Software-defined')
                #endregion Lookup arrays
                
                # Change the default output properties here
                $defaultProperties = @('ComputerName','Manufacturer','HealthState')
          
                Write-Verbose -Message ('Runspace {0}: Server general information' -f $ComputerName)                
                # Modify this variable to change your default set of display properties
                $WMI_CompProps = @('DNSHostName','Manufacturer')
                $wmi_compsystem = Get-WmiObject @WMIHast -Class Win32_ComputerSystem | Select-Object $WMI_CompProps
                if (($wmi_compsystem.Manufacturer -eq 'HP') -or ($wmi_compsystem.Manufacturer -like 'Hewlett*'))
                {
                    if (Get-WmiObject @WMIHast -Namespace 'root' -Class __NAMESPACE -filter "name='hpq'") 
                    {
                        #region HP General
                        Write-Verbose -Message ('Runspace {0}: HP general health information' -f $ComputerName)
                        $WMI_HPHealthProps = @('HealthState')
                        $wmi_hphealth = Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class  HP_WinComputerSystem | 
                                        Select-Object $WMI_HPHealthProps
                        
                        $ResultProperty = @{
                            ### Defaults
                            'PSComputerName' = $ComputerName
                            'ComputerName' = $wmi_compsystem.DNSHostName
                            'Manufacturer' = $wmi_compsystem.Manufacturer
                            'HealthState' = $Healthstatus[[string]$wmi_hphealth.HealthState]
                        }
                        #endregion HP General
                        
                        #region HP PSU
                        if ($IncludePSUHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP PSU health information' -f $ComputerName)
                            $WMI_HPPowerProps = @('ElementName','PowerSupplyType','HealthState')                
                            $wmi_hppower = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_WinPowerSupply | 
                                             Select-Object $WMI_HPPowerProps)
                            $_PSUHealth = @()
                            foreach ($psu in $wmi_hppower)
                            {
                                $psuprop = @{
                                    'Name' = $psu.ElementName
                                    'Type' = $PSUType[[int]$psu.PowerSupplyType]
                                    'HealthState' = $HealthStatus[[string]$psu.HealthState]
                                }
                                $_PSUHealth += New-Object PSObject -Property $psuprop
                            }
                            $ResultProperty._PSUHealth = @($_PSUHealth)
                        }
                        #endregion HP PSU
                        
                        #region HP Temperature Sensors
                        if ($IncludeTempSensors)
                        {                
                            Write-Verbose -Message ('Runspace {0}: HP sensor information' -f $ComputerName)
                            $WMI_HPTempSensorProps = @('ElementName','SensorType','Description','CurrentReading',`
                                                   'UpperThresholdCritical')
                            $wmi_hptempsensor = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_WinNumericSensor |
                                                Select-Object $WMI_HPTempSensorProps)
                            $_TempSensors = @()
                            foreach ($sensor in $wmi_hptempsensor)
                            {
                                $PercentCrit = 0
                                if (($sensor.CurrentReading) -and ($sensor.UpperThresholdCritical))
                                {
                                    $PercentCrit = [math]::round((($sensor.CurrentReading/$sensor.UpperThresholdCritical)*100), 2)
                                }
                                $sensorprop = @{
                                    'Name' = $sensor.ElementName
                                    'Type' = $SensorType[[int]$sensor.SensorType]
                                    'Description' = [regex]::Match($sensor.Description,"(.+)(?=\..+$)").Value
                                    'CurrentReading' = $sensor.CurrentReading
                                    'UpperThresholdCritical' = $sensor.UpperThresholdCritical
                                    'PercentToCritical' = $PercentCrit
                                }
                                $_TempSensors += New-Object PSObject -Property $sensorprop
                            }
                            $ResultProperty._TempSensors = @($_TempSensors)
                        }
                        #endregion HP Temperature Sensors              
                        
                        #region HP Ethernet Team
                        if ($IncludeEthernetTeamHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP ethernet team information' -f $ComputerName)
                            $WMI_HPEthTeamsProps = @('ElementName','Description','RedundancyStatus')
                            $wmi_ethernetteam = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_EthernetTeam |
                                                Select-Object $WMI_HPEthTeamsProps)
                            $_EthernetTeamHealth = @()
                            foreach ($ethteam in $wmi_ethernetteam)
                            {
                                $ethteamprop = @{
                                    'Name' = $ethteam.ElementName
                                    'Description' = $ethteam.Description
                                    'RedundancyStatus' = $TeamStatus[[string]$ethteam.RedundancyStatus]
                                }
                                $_EthernetTeamHealth += New-Object PSObject -Property $ethteamprop
                            }
                            $ResultProperty._EthernetTeamHealth = @($_EthernetTeamHealth)
                        }
                        #endregion HP Ethernet Team
                        
                        #region HP Fans
                        if ($IncludeFanHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP fan information' -f $ComputerName)
                            $WMI_HPFanProps = @('ElementName','HealthState','RemovalConditions')
                            $wmi_fans = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_FanModule |
                                          Select-Object $WMI_HPFanProps)
                            $_FanHealth = @()
                            foreach ($fan in $wmi_fans)
                            {
                                $fanprop = @{
                                    'Name' = $fan.ElementName
                                    'HealthState' = $HealthStatus[[string]$fan.HealthState]
                                    'RemovalConditions' = $FanRemovalConditions[[string]$fan.RemovalConditions]
                                }
                                $_FanHealth += New-Object PSObject -Property $fanprop
                            }
                            $ResultProperty._FanHealth = @($_FanHealth)
                        }
                        #endregion HP Fans
                        
                        #region HP Ethernet
                        if ($IncludeEthernetHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP ethernet information' -f $ComputerName)
                            $WMI_HPEthernetPortProps = @('ElementName','PortNumber','PortType','HealthState')
                            $wmi_ethernet = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HP_EthernetPort |
                                            Select-Object $WMI_HPEthernetPortProps)
                            $_EthernetHealth = @()
                            foreach ($eth in $wmi_ethernet)
                            {
                                $ethprop = @{
                                    'Name' = $eth.ElementName
                                    'HealthState' = $HealthStatus[[string]$eth.HealthState]
                                    'PortType' = $EthernetPortType[[string]$eth.PortType]
                                    'PortNumber' = $eth.PortNumber
                                }
                                $_EthernetHealth += New-Object PSObject -Property $ethprop
                            }
                            $ResultProperty._EthernetHealth = @($_EthernetHealth)
                        }
                        #endregion HP Ethernet
                                        
                        #region HBA
                        if ($IncludeHBAHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP HBA information' -f $ComputerName)
                            $WMI_HPFCPortProps = @('ElementName','Manufacturer','Model','OtherIdentifyingInfo','OperationalStatus')
                            $wmi_hba = @(Get-WmiObject @WMIHast -Namespace 'root\hpq' -Class HPFCHBA_PhysicalPackage |
                                       Select-Object $WMI_HPFCPortProps)
                            $_HBAHealth = @()
                            foreach ($hba in $wmi_hba)
                            {
                                $hbaprop = @{
                                    'Name' = $hba.ElementName
                                    'Manufacturer' = $hba.Manufacturer
                                    'Model' = $hba.Model
                                    'OtherIdentifyingInfo' = $hba.OtherIdentifyingInfo
                                    'OperationalStatus' = $OperationalStatus[[string]$hba.OperationalStatus]
                                }
                                $_HBAHealth += New-Object PSObject -Property $hbaprop
                            }
                            $ResultProperty._HBAHealth = @($_HBAHealth)
                        }
                        #endregion HBA
                        
                        #region ArrayControllers
                        if ($IncludeArrayControllerHealth)
                        {
                            Write-Verbose -Message ('Runspace {0}: HP array controller information' -f $ComputerName)
                            $WMI_ArrayCtrlProps = @('ElementName','BatteryStatus','ControllerStatus')
                            $wmi_arraycontroller = @(Get-WMIObject @WMIHast -Namespace 'root\hpq' -class HPSA_ArrayController | 
                                                   Select-Object $WMI_ArrayCtrlProps)
                            $_ArrayControllers = @()
                            Foreach ($array in $wmi_arraycontroller)
                            {
                                $BatteryStat = ''
                                if ($array.batterystatus)
                                {
                                    $BatteryStat = $BatteryStatus[[string]$array.batterystatus]
                                }
                                $arrayprop = @{
                                    'ArrayName' = $array.ElementName
                                    'BatteryStatus' = $BatteryStat
                                    'ControllerStatus' = $OperationalStatus[[string]$array.ControllerStatus]
                                }
                                $_ArrayControllers += New-Object PSObject -Property $arrayprop
                            }
                            $ResultProperty._ArrayControllers = $_ArrayControllers
                        }
                        #endregion ArrayControllers
                    }
                    else
                    {
                        Write-Warning -Message ('{0}: {1}' -f $ComputerName, 'WBEM Provider software needs to be installed')
                    }
                }
                else
                {
                    Write-Warning -Message ('{0}: {1}' -f $ComputerName, 'Not determined to be HP hardware')
                }

                    # Final output
                $ResultObject = New-Object -TypeName PSObject -Property $ResultProperty

                # Setup the default properties for output
                $ResultObject.PSObject.TypeNames.Insert(0,'My.HPServerHealth.Info')
                $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultProperties)
                $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                $ResultObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers

                Write-Output -InputObject $ResultObject

            }
            catch
            {
                Write-Warning -Message ('{0}: {1}' -f $ComputerName, $_.Exception.Message)
            }
            Write-Verbose -Message ('Runspace {0}: End' -f $ComputerName)
        }
 
        function Get-Result
        {
            [CmdletBinding()]
            Param 
            (
                [switch]$Wait
            )
            do
            {
                $More = $false
                foreach ($runspace in $runspaces)
                {
                    $StartTime = $runspacetimers.($runspace.ID)
                    if ($runspace.Handle.isCompleted)
                    {
                        Write-Verbose -Message ('Thread done for {0}' -f $runspace.IObject)
                        $runspace.PowerShell.EndInvoke($runspace.Handle)
                        $runspace.PowerShell.Dispose()
                        $runspace.PowerShell = $null
                        $runspace.Handle = $null
                    }
                    elseif ($runspace.Handle -ne $null)
                    {
                        $More = $true
                    }
                    if ($Timeout -and $StartTime)
                    {
                        if ((New-TimeSpan -Start $StartTime).TotalSeconds -ge $Timeout -and $runspace.PowerShell)
                        {
                            Write-Warning -Message ('Timeout {0}' -f $runspace.IObject)
                            $runspace.PowerShell.Dispose()
                            $runspace.PowerShell = $null
                            $runspace.Handle = $null
                        }
                    }
                }
                if ($More -and $PSBoundParameters['Wait'])
                {
                    Start-Sleep -Milliseconds 100
                }
                foreach ($threat in $runspaces.Clone())
                {
                    if ( -not $threat.handle)
                    {
                        Write-Verbose -Message ('Removing {0} from runspaces' -f $threat.IObject)
                        $runspaces.Remove($threat)
                    }
                }
                if ($ShowProgress)
                {
                    $ProgressSplatting = @{
                        Activity = 'Getting asset info'
                        Status = '{0} of {1} total threads done' -f ($bgRunspaceCounter - $runspaces.Count), $bgRunspaceCounter
                        PercentComplete = ($bgRunspaceCounter - $runspaces.Count) / $bgRunspaceCounter * 100
                    }
                    Write-Progress @ProgressSplatting
                }
            }
            while ($More -and $PSBoundParameters['Wait'])
        }
    }
    PROCESS
    {
        foreach ($Computer in $ComputerName)
        {
            $bgRunspaceCounter++
            $psCMD = [System.Management.Automation.PowerShell]::Create().AddScript($ScriptBlock)
            $null = $psCMD.AddParameter('bgRunspaceID',$bgRunspaceCounter)
            $null = $psCMD.AddParameter('ComputerName',$Computer)
            $null = $psCMD.AddParameter('IncludePSUHealth',$IncludePSUHealth)       
            $null = $psCMD.AddParameter('IncludeTempSensors',$IncludeTempSensors)
            $null = $psCMD.AddParameter('IncludeEthernetTeamHealth',$IncludeEthernetTeamHealth)
            $null = $psCMD.AddParameter('IncludeFanHealth',$IncludeFanHealth)
            $null = $psCMD.AddParameter('IncludeEthernetHealth',$IncludeEthernetHealth)
            $null = $psCMD.AddParameter('IncludeHBAHealth',$IncludeHBAHealth)
            $null = $psCMD.AddParameter('IncludeArrayControllerHealth',$IncludeArrayControllerHealth)
            $null = $psCMD.AddParameter('Verbose',$VerbosePreference) # Passthrough the hidden verbose option so write-verbose works within the runspaces
            $psCMD.RunspacePool = $rp
 
            Write-Verbose -Message ('Starting {0}' -f $Computer)
            [void]$runspaces.Add(@{
                Handle = $psCMD.BeginInvoke()
                PowerShell = $psCMD
                IObject = $Computer
                ID = $bgRunspaceCounter
                })
           Get-Result
        }
    }
    END
    {
        Get-Result -Wait
        if ($ShowProgress)
        {
            Write-Progress -Activity 'Getting HP health info' -Status 'Done' -Completed
        }
        Write-Verbose -Message 'Closing runspace pool'
        $rp.Close()
        $rp.Dispose()
    }
}