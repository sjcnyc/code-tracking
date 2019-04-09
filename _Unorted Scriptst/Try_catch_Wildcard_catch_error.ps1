Try {
    $HostInfo = Get-VMHost -Name $VMHostName -ErrorAction Stop
}
Catch {

    switch -wildcard ($_.exception.message) {
        '*You are not currently connected to any servers*' {
            Write-Error "No VCenter Connection is available."
        }
        '*was not found using the specified filter(s)*' {
            Write-Error "No Host of that name exists on the VCenter server you are connected to."
        }
        Default {
            Write-Error "$($_.exception.message)"
        }
    }