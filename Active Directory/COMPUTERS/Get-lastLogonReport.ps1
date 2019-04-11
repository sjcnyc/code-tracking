function Get-lastLogonReport {
  param (
    [Parameter(Mandatory=$true)][string]$SearchRoot,
    [Parameter(Mandatory=$true)][string]$Name
  )

  $QADParams = @{
    SizeLimit                        = '0'
    PageSize                         = '2000'
    DontUseDefaultIncludedProperties = $true
    IncludedProperties               = @('Name', 'LastLogonTimeStamp', 'OSName', 'ParentContainerDN')
    SearchRoot                       = @("bmg.bagint.com/$($SearchRoot)")
  }

  $days = '30'
  $Currentdate = Get-Date


  Get-QADComputer @QADParams | Select-Object -Property name, osname, lastlogontimestamp, parentcontainer -ErrorAction SilentlyContinue |
   Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt $days} |
   Export-Csv -Path "C:\TEMP\$($Name).csv" -NoTypeInformation

}
