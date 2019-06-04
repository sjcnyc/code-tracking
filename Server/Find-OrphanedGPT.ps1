function Find-OrphanedGPT {
    [cmdletbinding()]
    param (
        [parameter(mandatory=$false)]$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
    )
    # Static variables
    $DomainName = $Domain.Name
    $DomainDistinguishedName = $Domain.GetDirectoryEntry() | Select-Object -ExpandProperty DistinguishedName
    $GPOPoliciesDN = "CN=Policies,CN=System,$DomainDistinguishedName"
    $GPOPoliciesSysVolUNC = "\\$DomainName\SYSVOL\$DomainName\Policies"
    $GPOPoliciesADSI = [ADSI]"LDAP://$GPOPoliciesDN"
    [array]$GPOPolicies = $GPOPoliciesADSI.psbase.children

    # Loop through the GPO's and GPT's
    foreach ($GPO in $GPOPolicies) { 
        [array]$DomainGPOList += $GPO.Name
    }
    [array]$GPOPoliciesSysvol = Get-ChildItem $GPOPoliciesSysvolUNC
    foreach ($GPO in $GPOPoliciesSysvol) {
        if ($GPO.Name -ne 'PolicyDefinitions') {
            [array]$SysvolGPOList += $GPO.Name 
        }
    }
    # Check for GPTs in SYSVOL that don't exist in AD
    [array]$OrphanedGPTs = Compare-Object $SYSVOLGPOList $DomainGPOList -passThru | Where-Object { $_.SideIndicator -eq '<=' }
    foreach ($OrphanedGPT in $OrphanedGPTs) {
        $Object = New-Object -TypeName PSObject
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'GUID' -Value $OrphanedGPT
        $Object | Add-Member -MemberType 'NoteProperty' -Name 'Path' -Value (Join-Path $GPOPoliciesSysVolUNC $OrphanedGPT)
        $Object
    }
}

