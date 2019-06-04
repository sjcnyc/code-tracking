﻿Function Get-ServerInfo {
    [CmdletBinding()]
    Param (
        [parameter(ValueFromPipeline = $True)]
        [string[]]$ComputerName
    )

    Begin {
        #Initialize
        Write-Verbose 'Initializing'
    }

    Process {
        if (!($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)) {
            Write-Host "Processing $ComputerName"
        }

        Write-Verbose "=====> Processing $ComputerName <====="

        $htmlreport = @()
        $htmlbody = @()
        $htmlfile = "$($ComputerName).html"
        $spacer = '<br />'

        try {
            $bestping = (Test-Connection -ComputerName $ComputerName -Count 10 -ErrorAction STOP | Sort-Object ResponseTime)[0].ResponseTime
        }
        catch {
            Write-Warning $_.Exception.Message
            $bestping = 'Unable to connect'
        }

        if ($bestping -eq 'Unable to connect') {
            if (!($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)) {
                Write-Host "Unable to connect to $ComputerName"
            }

            "Unable to connect to $ComputerName"
        }
        else {
            Write-Verbose 'Collecting computer system information'

            $subhead = '<h3>Computer System Information</h3>'
            $htmlbody += $subhead

            try {
                $csinfo = Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object Name, Manufacturer, Model,
                @{Name = 'Physical Processors'; Expression = {$_.NumberOfProcessors}},
                @{Name = 'Logical Processors'; Expression = {$_.NumberOfLogicalProcessors}},
                @{Name = 'Total Physical Memory (Gb)'; Expression = {
                        $tpm = $_.TotalPhysicalMemory / 1GB;
                        '{0:F0}' -f $tpm
                    }
                },
                DnsHostName, Domain

                $htmlbody += $csinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer

            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            Write-Verbose 'Collecting operating system information'

            $subhead = '<h3>Operating System Information</h3>'
            $htmlbody += $subhead

            try {
                $osinfo = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object @{Name = 'Operating System'; Expression = {$_.Caption}},
                @{Name = 'Architecture'; Expression = {$_.OSArchitecture}},
                Version, Organization,
                @{Name = 'Install Date'; Expression = {
                        $installdate = [datetime]::ParseExact($_.InstallDate.SubString(0, 8), 'yyyyMMdd', $null);
                        $installdate.ToShortDateString()
                    }
                },
                WindowsDirectory

                $htmlbody += $osinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            Write-Verbose 'Collecting physical memory information'

            $subhead = '<h3>Physical Memory Information</h3>'
            $htmlbody += $subhead

            try {
                $memorybanks = @()
                $physicalmemoryinfo = @(Get-WmiObject Win32_PhysicalMemory -ComputerName $ComputerName -ErrorAction STOP |
                        Select-Object DeviceLocator, Manufacturer, Speed, Capacity)

                foreach ($bank in $physicalmemoryinfo) {
                    $memObject = New-Object PSObject
                    $memObject | Add-Member NoteProperty -Name 'Device Locator' -Value $bank.DeviceLocator
                    $memObject | Add-Member NoteProperty -Name 'Manufacturer' -Value $bank.Manufacturer
                    $memObject | Add-Member NoteProperty -Name 'Speed' -Value $bank.Speed
                    $memObject | Add-Member NoteProperty -Name 'Capacity (GB)' -Value ('{0:F0}' -f $bank.Capacity / 1GB)

                    $memorybanks += $memObject
                }

                $htmlbody += $memorybanks | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>PageFile Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting pagefile information'

            try {
                $pagefileinfo = Get-WmiObject Win32_PageFileUsage -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object @{Name = 'Pagefile Name'; Expression = {$_.Name}},
                @{Name = 'Allocated Size (Mb)'; Expression = {$_.AllocatedBaseSize}}

                $htmlbody += $pagefileinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>BIOS Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting BIOS information'

            try {
                $biosinfo = Get-WmiObject Win32_Bios -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object Status, Version, Manufacturer,
                @{Name = 'Release Date'; Expression = {
                        $releasedate = [datetime]::ParseExact($_.ReleaseDate.SubString(0, 8), 'yyyyMMdd', $null);
                        $releasedate.ToShortDateString()
                    }
                },
                @{Name = 'Serial Number'; Expression = {$_.SerialNumber}}

                $htmlbody += $biosinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>Logical Disk Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting logical disk information'

            try {
                $diskinfo = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object DeviceID, FileSystem, VolumeName,
                @{Expression = {$_.Size / 1Gb -as [int]}; Label = 'Total Size (GB)'},
                @{Expression = {$_.Freespace / 1Gb -as [int]}; Label = 'Free Space (GB)'}

                $htmlbody += $diskinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>Volume Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting volume information'

            try {
                $volinfo = Get-WmiObject Win32_Volume -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object Label, Name, DeviceID, SystemVolume,
                @{Expression = {$_.Capacity / 1Gb -as [int]}; Label = 'Total Size (GB)'},
                @{Expression = {$_.Freespace / 1Gb -as [int]}; Label = 'Free Space (GB)'}

                $htmlbody += $volinfo | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>Network Interface Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting network interface information'

            try {
                $nics = @()
                $nicinfo = @(Get-WmiObject Win32_NetworkAdapter -ComputerName $ComputerName -ErrorAction STOP | Where-Object {$_.PhysicalAdapter} |
                        Select-Object Name, AdapterType, MACAddress,
                    @{Name = 'ConnectionName'; Expression = {$_.NetConnectionID}},
                    @{Name = 'Enabled'; Expression = {$_.NetEnabled}},
                    @{Name = 'Speed'; Expression = {$_.Speed / 1000000}})

                $nwinfo = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -ErrorAction STOP |
                    Select-Object Description, DHCPServer,
                @{Name = 'IpAddress'; Expression = {$_.IpAddress -join '; '}},
                @{Name = 'IpSubnet'; Expression = {$_.IpSubnet -join '; '}},
                @{Name = 'DefaultIPgateway'; Expression = {$_.DefaultIPgateway -join '; '}},
                @{Name = 'DNSServerSearchOrder'; Expression = {$_.DNSServerSearchOrder -join '; '}}

                foreach ($nic in $nicinfo) {
                    $nicObject = New-Object PSObject
                    $nicObject | Add-Member NoteProperty -Name 'Connection Name' -Value $nic.connectionname
                    $nicObject | Add-Member NoteProperty -Name 'Adapter Name' -Value $nic.Name
                    $nicObject | Add-Member NoteProperty -Name 'Type' -Value $nic.AdapterType
                    $nicObject | Add-Member NoteProperty -Name 'MAC' -Value $nic.MACAddress
                    $nicObject | Add-Member NoteProperty -Name 'Enabled' -Value $nic.Enabled
                    $nicObject | Add-Member NoteProperty -Name 'Speed (Mbps)' -Value $nic.Speed

                    $ipaddress = ($nwinfo | Where-Object {$_.Description -eq $nic.Name}).IpAddress
                    $nicObject | Add-Member NoteProperty -Name 'IPAddress' -Value $ipaddress

                    $nics += $nicObject
                }

                $htmlbody += $nics | ConvertTo-Html -Fragment
                $htmlbody += $spacer
            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            $subhead = '<h3>Software Information</h3>'
            $htmlbody += $subhead

            Write-Verbose 'Collecting software information'

            try {
                $software = Get-WmiObject Win32_Product -ComputerName $ComputerName -ErrorAction STOP | Select-Object Vendor, Name, Version | Sort-Object Vendor, Name

                $htmlbody += $software | ConvertTo-Html -Fragment
                $htmlbody += $spacer

            }
            catch {
                Write-Warning $_.Exception.Message
                $htmlbody += "<p>An error was encountered. $($_.Exception.Message)</p>"
                $htmlbody += $spacer
            }

            Write-Verbose 'Producing HTML report'

            $reportime = Get-Date

            #Common HTML head and styles
            $htmlhead = "<html>
				    <style>
				    BODY{font-family: Arial; font-size: 8pt;}
				    H1{font-size: 20px;}
				    H2{font-size: 18px;}
				    H3{font-size: 16px;}
				    TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
				    TH{border: 1px solid black; background: #dddddd; padding: 5px; color: #000000;}
				    TD{border: 1px solid black; padding: 5px; }
				    td.pass{background: #7FFF00;}
				    td.warn{background: #FFE600;}
				    td.fail{background: #FF0000; color: #ffffff;}
				    td.info{background: #85D4FF;}
				    </style>
				    <body>
				    <h1 align=""center"">Server Info: $ComputerName</h1>
				    <h3 align=""center"">Generated: $reportime</h3>"

            $htmltail = '</body></html>'

            $htmlreport = $htmlhead + $htmlbody + $htmltail
            $htmlreport | Out-File $htmlfile -Encoding Utf8
        }
    }
}