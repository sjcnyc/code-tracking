Function Get-LastLogon {
    [CmdletBinding()] 
    param( 
        [Parameter(Position = 0, ValueFromPipeline = $true)] 
        [Alias('CN', 'Computer')] 
        [String[]]$ComputerName = "$env:COMPUTERNAME" 
    ) 
 
    Begin {  
        $TempErrAct = $ErrorActionPreference 
        $ErrorActionPreference = 'Stop' 
    }
 
    Process { 
        Foreach ($Computer in $ComputerName) { 
            $Computer = $Computer.ToUpper().Trim() 
            Try { 
                $Win32OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer 
                $Build = $Win32OS.BuildNumber 
                If ($Build -ge 6001) { 
                    $Win32User = Get-WmiObject -Class Win32_UserProfile -ComputerName $Computer 

                    $Win32User = $Win32User | Where-Object -FilterScript {($_.SID -notmatch "^S-1-5-\d[18|19|20]$")} 
                    $Win32User = $Win32User | Sort-Object -Property LastUseTime -Descending 
                    $LastUser = $Win32User | Select-Object -First 1 
                    $Loaded = $LastUser.Loaded 
                    $Time = ([WMI]'').ConvertToDateTime($LastUser.LastUseTime) 
                 
                    $UserSID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ($LastUser.SID) 
                    $User = $UserSID.Translate([System.Security.Principal.NTAccount]) 
                 
                    $UserProf = New-Object -TypeName PSObject -Property @{
                        Computer          = $Computer
                        User              = $User.value.split('\')[-1]
                        Time              = $Time
                        CurrentlyLoggedOn = $Loaded
                        OS                = $Win32OS.name.Split('|')[0]
                    } 
                 
                    $UserProf = $UserProf | Select-Object -Property Computer, User, Time, CurrentlyLoggedOn
                    $UserProf 
                }
                If ($Build -le 6000) { 
                    If ($Build -eq 2195) 
                    {$SysDrv = $Win32OS.SystemDirectory.ToCharArray()[0] + ':'}#End If ($Build -eq 2195) 
                    Else 
                    {$SysDrv = $Win32OS.SystemDrive}#End Else
                    $SysDrv = $SysDrv.Replace(':', "$") 
                    $ProfDrv = '\\' + $Computer + '\' + $SysDrv 
                    $ProfLoc = Join-Path -Path $ProfDrv -ChildPath 'Documents and Settings' 
                    $Profiles = Get-ChildItem -Path $ProfLoc 
                    $LastProf = $Profiles | ForEach-Object -Process {$_.GetFiles('ntuser.dat.LOG')} 
                    $LastProf = $LastProf |
                        Sort-Object -Property LastWriteTime -Descending |
                        Select-Object -First 1 
                    $UserName = $LastProf.DirectoryName.Replace("$ProfLoc", '').Trim('\').ToUpper() 
                    $Time = $LastProf.LastAccessTime 
                 
                    $Sddl = $LastProf.GetAccessControl().Sddl 
                    $Sddl = $Sddl.split('(') |
                        Select-String -Pattern "[0-9]\)$" |
                        Select-Object -First 1 

                    $Sddl = $Sddl.ToString().Split(';')[5].Trim(')') 

                    $TranSID = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList ($UserName) 
                    $UserSID = $TranSID.Translate([System.Security.Principal.SecurityIdentifier])
                    If ($Sddl -eq $UserSID) { 
                        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]'Users', $Computer) 
                        $Loaded = $Reg.GetSubKeyNames() -contains $UserSID.Value 

                        $UserSID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ($UserSID) 
                        $User = $UserSID.Translate([System.Security.Principal.NTAccount]) 
                    }
                    Else { 
                        $User = $UserName 
                        $Loaded = 'Unknown' 
                    }

                    $UserProf = New-Object -TypeName PSObject -Property @{
                        Computer          = $Computer
                        User              = $User.value.split('\')[-1]
                        Time              = $Time
                        CurrentlyLoggedOn = $Loaded
                        OS                = $Win32OS.name.Split('|')[0]
                    }                 

                    $UserProf = $UserProf | Select-Object -Property Computer, User, Time, CurrentlyLoggedOn
                    $UserProf
                }
            }
            Catch 
            {}
        } 
    }
    End {     
        $ErrorActionPreference = $TempErrAct 
    }
}
