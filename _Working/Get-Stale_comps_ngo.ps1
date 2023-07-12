$StaleThreshold = 90



$DaysAgo = (Get-Date).AddDays(-$StaleThreshold)
  $Date = (get-date -f yyyy-MM-dd)
  $CSVFile = "C:\temp\StaleComputerAccounts_$($StaleThreshold)_Days_$($Date).csv"

  $ADObjectSplat = @{
    Filter     = { LastLogonTimeSTamp -lt $DaysAgo}
    Properties = 'PwdLastSet', 'LastLogonTimeStamp', 'Description', 'distinguishedName', 'SamAccountName', 'CanonicalName', 'Name'
    Server     = $Domain
  }

  $stdous = Get-ADOrganizationalUnit -filter "DistinguishedName -like 'OU=Win10,OU=Workstations*Tier-2'" -or DistinguishedName -like "OU=Mac,OU=Workstations*Tier-2*"} #| Where-Object { $_.distinguishedname -like "OU=Win10,OU=Workstations*Tier-2*" -or $_.distinguishedname -like "OU=Mac,OU=Workstations*Tier-2*" }

  $StaleAccounts = foreach ($stdou in $stdous) {
    Get-ADComputer @ADObjectSplat -SearchBase $stdou.distinguishedName
  }

  $StaleAccounts | Export-Csv $CSVFile