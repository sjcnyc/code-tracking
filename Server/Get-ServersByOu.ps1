#Add-PSSnapin Quest.ActiveRoles.ADManagement

function Get-ServersByOu 
{
  param (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)][array]$ous)
  
  begin{} 
  process {
    try 
    {
      $ous |
      ForEach-Object -Process {
        $comps =  Get-QADComputer -SizeLimit '0' -IncludeAllProperties -SearchRoot bmg.bagint.com/$_ -OSName 'Windows*Server*' | 
        Select-Object -Property Name, Description, @{
          N = 'IPAddress'
          E = {
            ([Net.Dns]::GetHostAddresses($_.name).IPAddressToString)
          }         
        }
      }
    } 
    catch 
    {
      $_.exception.message
      continue
    }
  }
  end{
  
     $comps  | Export-Csv -Path 'c:\temp\usa_servers_All2.csv' -NoTypeInformation -Append  
  }
}

# pass array of ous
Get-ServersByOu -ous usa 