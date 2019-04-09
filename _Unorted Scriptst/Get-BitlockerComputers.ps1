workflow Get-BitlockedComputers {
    Param(
        [Parameter(Mandatory = $true,
            Position = 0)]
        [Alias('Name')]
        [string[]]$ComputerName
    )
    foreach -parallel ($c in $ComputerName) {
        inlinescript {
            $c = $using:c

            $BitlockerVolumes = Get-CimInstance -Namespace 'Root\cimv2\Security\MicrosoftVolumeEncryption' -Class 'Win32_EncryptableVolume' -ErrorAction SilentlyContinue -ErrorVariable CimErr -ComputerName $c |
            Where-Object {$_.ProtectionStatus -eq 'on'}

            $obj = [ordered]@{}
            $obj.Add('ComputerName', $c)
            if ($CimErr -eq $null) {
                $obj.Add('BitLocked', 'Unknown')
                Remove-Variable -Name CimErr
            }
            elseif ($BitlockerVolumes -eq $null) {
                $obj.Add('Bitlocked', $false)
            }
            else {
                $obj.Add('Bitlocked', $true)
            }
            $output = New-Object -TypeName PSObject -Property $obj
            Write-Output $output
        }
    }
}

$Computers = Get-ADComputer -Filter * -SearchBase 'OU=Windows7,OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' -SearchScope Subtree | Select-Object DistinguishedName, name

foreach ($computer in $Computers) {


    Invoke-Command -ScriptBlock { Get-BitLockerVolume } -ComputerName $computer.Name | Select-Object ComputerName, MountPoint, VolumeStatus, ProtectionStatus
}


Get-BitlockedComputers -ComputerName $Computers | Select-Object ComputerName, Bitlocked | Export-Csv C:\Temp\bitlockered_computers.csv -NoTypeInformation