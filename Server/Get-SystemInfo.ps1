$command = { systeminfo.exe /FO CSV | ConvertFrom-Csv };
Invoke-Command -ScriptBlock $command


$command = { systeminfo.exe /FO CSV | ConvertFrom-Csv  }

$remotecode =
{
    param($Code)
    $job = Start-Job ([ScriptBlock]::Create($Code)) -Name Job1
    $null = Wait-Job $job
    Receive-Job -Name Job1
    Remove-Job -Name Job1
}

Invoke-Command -ComputerName Server01 -ScriptBlock $remotecode -ArgumentList $command