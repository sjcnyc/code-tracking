function Move-DisabledComputers {
    param(
        [string]$ComputerName,
        [string]$TargetOu = 'CN=USL507B9D4B93DD,OU=Win10Test,OU=Windows10,OU=WST,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
    )
    try {
        $dn = (Get-QADComputer -identity $ComputerName).DN
        Enable-QADComputer -Identity $ComputerName
        Write-Output "Enabling : $($ComputerName)"
        Move-QADObject -Identity $dn -NewParentContainer $TargetOu
        Write-Output "Moving $($ComputerName) to $(TargetOu)"
    }
    catch {
        $_.Exception.Message
    }
}