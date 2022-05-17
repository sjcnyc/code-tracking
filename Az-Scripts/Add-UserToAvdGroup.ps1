function Add-UserToAvdGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$sAMAccountName,

        [Parameter(Mandatory = $true)]
        [string]$Groups
    )
    try {
        foreach ($Group in $Groups) {
            $GroupDN = (Get-ADGroup -Identity $Group).DistinguishedName
            if (-not (Get-ADGroupMember -Identity $GroupDN | Where-Object {$_.sAMAccountName -eq $sAMAccountName})) {
                Add-ADGroupMember -Identity $GroupDN -Members $sAMAccountName
                Write-Host "Adding $($sAMAccountName) to AVD group: $($Group)" -ForegroundColor Green
            } else {
                Write-Host "User $($sAMAccountName) already in AVD group: $($Group)" -ForegroundColor Red
            }
        }
    } catch {
        $_.Exception.message
    }
}

Register-ArgumentCompleter -CommandName 'Add-UserToAvdGroup' -ParameterName 'Groups' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    (Get-ADGroup -Filter 'Name -like "az_avd_*FullDesktop"' -prop Name).Name | ForEach-Object { "'$_'" }
}