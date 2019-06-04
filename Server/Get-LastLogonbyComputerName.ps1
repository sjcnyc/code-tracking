#Add-PSSnapin Quest.ActiveRoles.ADManagement -ea 0

function Get-Lastlogon {
  param
  (
    [System.Object]
    $computer
  )

  Get-WmiObject Win32_NetworkLoginProfile -ComputerName $computer e|
  Sort-Object -Descending LastLogon |
  Select-Object * -First 1 |
  Where-Object {$_.LastLogon -match '(\d{14})'} |
  ForEach-Object {
    New-Object PSObject -Property @{
                Name=$_.Name ;
                LastLogon=[datetime]::ParseExact($matches[0], 'yyyyMMddHHmmss', $null)
            }
  }
}