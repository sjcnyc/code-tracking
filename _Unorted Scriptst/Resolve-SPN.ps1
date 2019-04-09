function Resolve-SPN {
    ################################################################
    #.Synopsis
    #  Resolves the provided SPN and checks for duplicate entries 
    #.Parameter SPN
    #  The SPN to perform the check against
    ################################################################
    param( [Parameter(Mandatory = $true)][string]$SPN)

    $Filter = "(ServicePrincipalName=$SPN)"
    $Searcher = New-Object System.DirectoryServices.DirectorySearcher
    $Searcher.Filter = $Filter
    $SPNEntry = $Searcher.FindAll()
    $Count = $SPNEntry | Measure-Object 
 
    if ($Count.Count -gt 1) { 
        Write-Host "Duplicate SPN Found!" -ForegroundColor Red -BackgroundColor Black 
        Write-Host "The following Active Directory objects contains the SPN $SPN :" 
        $SPNEntry | Format-Table Path -HideTableHeaders 
    } 

    elseif ($Count.Count -eq 1) { 
        Write-Host "No duplicate SPN found" -ForegroundColor Green 
        Write-Host "The following Active Directory objects contains the SPN $SPN :" 
        $SPNEntry | Format-Table Path -HideTableHeaders
    } 

    else
    { 
        Write-Host "SPN not found" 
    }
}
 
#Imports the PowerShell ActiveDirectory available in Windows Server 2008 R2 and Windows 7 Remote Server Administration Tools (RSAT)
Import-Module ActiveDirectory 
 
function Resolve-AllDuplicateDomainSPNs {
    ################################################################
    #.Synopsis
    #  #  Resolves all domain SPNs and checks for duplicate entries
    ################################################################

    $DomainSPNs = ActiveDirectory\Get-ADObject -LDAPFilter "(ServicePrincipalName=*)" -Properties ServicePrincipalName -Server me.sonymusic.com

    foreach ($item in $DomainSPNs) {
        $SPNCollection = $item.ServicePrincipalName

        foreach ($SPN in $SPNCollection) {
            $Filter = "(ServicePrincipalName=$SPN)" 
            $Searcher = New-Object System.DirectoryServices.DirectorySearcher
            $Searcher.Filter = $Filter
            $SPNEntry = $Searcher.FindAll() 
            $Count = $SPNEntry | Measure-Object

            if ($count.Count -gt 1) { 
                Write-Host "Warning: Duplicate SPN Found!" -ForegroundColor Red -BackgroundColor Black
                Write-Host "The following Active Directory objects contains the SPN $SPN :" 
                $SPNEntry | Format-Table Path -HideTableHeaders
            }
        }
    }
}