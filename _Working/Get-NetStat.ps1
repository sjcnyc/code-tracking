function Get-NetStat {
    param (
        [string]$ComputerName,
        [string]$LogPath = '\\storage.bmg.bagint.com\wwinfra$\BmgDCLogs\'
    )
    process {
        $ScriptBlock = { netstat.exe -N | Where-Object { $_.Contains('389') } }
        $Data = Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName -ErrorAction Continue
        $Data = $Data[4..$Data.count]
        foreach ($line in $Data) {
            $Line = $Line -replace '^\s+', ''
            $Line = $Line -split '\s+'

            $Props = [pscustomobject]@{
                ComputerName       = $ComputerName
                Protocol           = $Line[0]
                LocalAddressIP     = ($Line[1] -split ':')[0]
                LocalAddressPort   = ($Line[1] -split ':')[1]
                ForeignAddressIP   = ($Line[2] -split ':')[0]
                ForeignAddressPort = ($Line[2] -split ':')[1]
                State              = $Line[3]
                Date               = Get-Date
            }
            $Props | Export-Csv "$($LogPath)$($ComputerName)_NetStat_389.csv" -Append -NoTypeInformation
        }
    }
}

@'
NYCSMEADS0011
NYCSMEADS0012
BERSMEADS0010
BVHSMEADS0010
FLLSMEADS0010
GTLSMEADS0010
GTLSMEADS0011
GTLSMEADS0012
GTLSMEADS0013
HKGSMEADS0010
JNBSMEADS0010
LONSMEADS0010
MXCSMEADS0010
MADSMEADS0010
MILSMEADS0010
MUCSMEADS0004
NASSMEADS0010
NYCMNETADS003
NYCSMEADS0010
STOSMEADS0010
SYDSMEADS0010
PARSMEADS0010
TORSMEADS0010
'@ -split [environment]::NewLine | ForEach-Object {

    Get-NetStat -ComputerName $_
}