Add-PSSnapin -Name Quest.ActiveRoles.ADManagement
function Test-Computer {
  param (
    [parameter(Mandatory,ValueFromPipeline, ValueFromPipelineByPropertyName, ValueFromRemainingArguments=$true)]
    [string]$computername
  )

try
{
    $result = [pscustomobject]@{
      DomainController = $computername
      IPAddress        = [Net.Dns]::GetHostAddresses($computername).IPAddressToString
      Status           = 'Unavailable'
    }
    if (Test-Connection -ComputerName $computername -Count 1 -Quiet){
      $result.Status = 'Available'
    }
    Write-Output $result
}
catch
{
    $line = $_.InvocationInfo.ScriptLineNumber
    ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}

$computers = Get-QADComputer -ComputerRole 'DomainController' |  Select-Object Name | Sort-Object -Descending

foreach ($computername in $computers)
{
  Test-Computer -computername $computername.Name
}