#requires -Module ActiveDirectory

[CmdletBinding(SupportsShouldProcess)]
Param(
    [Parameter(Mandatory = $true)][string]$CSVPath,
    [Parameter(Mandatory)][ValidateSet('ME', 'MNET')]$Domain,
    [Parameter(Mandatory)][ValidateSet('OldOU', 'NewOU')]$Moveto
)

Add-Type -AssemblyName Microsoft.ActiveDirectory.Management
try {
    switch ($Domain) {
        ME {
            'CULSMEADS0101.me.sonymusic.com' 
            Break
        }
        MNET {
            'nycmnetads001.mnet.biz:389' 
            Break
        }
    }
  
    if ($Domain -eq 'MNET') {
        $ou = 'OU=O365-NoSync,DC=mnet,DC=biz'
    }
    elseif ($doamin -eq 'ME') {
        $ou = 'OU=ADL,OU=zLegacy,DC=me,DC=sonymusic,DC=com'
    }

    Import-Csv -Path $CSVPath | ForEach-Object -Process {
        $userDN = (Get-ADUser -Identity $_.SamAccountName -Server $Domain).DistinguishedName        

        if ($Moveto -eq 'NewOU') {
            Move-ADObject -Identity $userDN -TargetPath $ou -Server $Domain
            Write-Output -InputObject ('Moving User: {0} to: {1}' -f $_.SamAccountName, $ou)
        }
        elseif ($Moveto -eq 'OldOU') {
            Move-ADObject -Identity $userDN -TargetPath $OldParent -Server $Domain
            Write-Output -InputObject ('Moving User: {0} to: {1}' -f $_.SamAccountName, $OldParent)
        }
    }
}
catch [Microsoft.ActiveDirectory.Management.ADException] {
    [Management.Automation.ErrorRecord]$e = $_

    $info = [PSCustomObject]@{
        Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
    }
    Write-Output -InputObject $info.Exception
}