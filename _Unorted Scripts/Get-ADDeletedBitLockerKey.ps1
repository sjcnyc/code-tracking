Function Get-ADDeletedBitLockerKey {
    <# 
    .SYNOPSIS 
        Get the bitlocker of deleted active directory computer.
    .DESCRIPTION
        This cmdlet uses the ActiveDirectory PowerShell module and retrieve the Bitlocker key, the suppression date and the computer name. 
    .PARAMETER ComputerName 
        The name of the computer's bitlocker key. 
        This parameter accepts a String[], and also allows pipeline input. 
    .EXAMPLE 
        'Computer1','Computer2','Computer3' |  Get-ADDeletedBitLockerKey 
    .EXAMPLE 
        Get-Content .\computers.txt | Get-ADDeletedBitLockerKey | Out-GridView 
    .EXAMPLE 
        Get-ADDeletedBitLockerKey -Verbose -ComputerName Computer1,Computer2,Computer3 
    .LINK 
        http://ItForDummies.net 
    #> 
    [cmdletbinding()] 
    Param( 
        [Parameter(Mandatory = $true, 
            Position = 1, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $True, 
            HelpMessage = 'Provide a ComputerName')] 
        [String[]]$ComputerName 
    ) 
    Begin {Import-Module ActiveDirectory -Verbose:$false} 
 
    Process { 
        ForEach ($Computer in $ComputerName) { 
            [System.Collections.ArrayList]$list = @() 
            Write-Verbose -Message "Searching for the deleted object..." 
            $DeletedComputer = Get-ADObject -LDAPFilter "CN=$Computer*" -IncludeDeletedObjects -SearchBase "CN=Deleted Objects,$((Get-ADRootDSE).defaultNamingContext)" -properties whenChanged
            if ($DeletedComputer) { 
                Write-Verbose -Message "Searching for the bitlocker object..." 
                foreach ($CurrentComputer in $DeletedComputer) { 
                    $BitLocker = Get-ADObject -Filter {objectClass -eq 'msFVE-RecoveryInformation'} -IncludeDeletedObjects -Properties LastKnownParent, 'msFVE-RecoveryPassword' |
                    Where-Object {$_.LastKnownParent -eq "$($CurrentComputer.DistinguishedName)"}
                    Write-Verbose -Message "Generating output.."
                    $Object = [PSCustomObject]@{
                        'ComputerName' = $CurrentComputer.Name.split('')[0]
                        'BitLockerKey' = $BitLocker.'msFVE-RecoveryPassword'
                        'Date'         = $CurrentComputer.whenChanged
                    }
                    [void]$list.add($Object)
                }
                $list
            } 
            else {"Computer not found in the deleted objects."}
        } 
    } 
    End {}
}