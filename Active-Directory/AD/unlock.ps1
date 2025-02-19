[CmdletBinding(SupportsShouldProcess)]
Param(
    [string]$UserAccount
)

Import-Module -Name ActiveDirectory

if ($UserAccount -ne $null) {
    $DClist = (Get-ADDomainController -Filter *).Name -split [environment]::NewLine
    Try {
        $User = Get-ADUser $UserAccount -Properties *
        Foreach ($targetDC in $DClist) {
            ('Processing {0} on DC {1}' -f ($User.SamAccountName), ($targetDC)) | Out-Default
            Try {
                    $null = Unlock-ADAccount -Identity $User.SamAccountName -Server $targetDC -ErrorAction SilentlyContinue
                    Write-Output -InputObject (('Completed on {0}' -f ($targetDC)))
            }
            Catch {
                $errormsg = ('{0} is down/not responding.' -f ($targetDC))
                Write-Output -InputObject $errormsg
            }
        }
    }
    Catch {
        $errormsg = ('{0} is an INVALID account. Check to see if it exists and that this is the SAM name.' -f ($User))
        Write-Output -InputObject $errormsg
    }
}
else {
    Write-Output -InputObject 'INVALID Parameters!'
    Write-Output -InputObject 'USAGE: unlock.ps1 <USERNAME>'
}