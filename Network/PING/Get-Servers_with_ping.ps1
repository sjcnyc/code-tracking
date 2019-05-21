Add-PSSnapin Quest.ActiveRoles.ADManagement

function test-computer {            
[CmdletBinding()]            
param (            
 [parameter(ValueFromPipeline=$true,             
   ValueFromPipelineByPropertyName=$true,            
   ValueFromRemainingArguments=$true)]            
 [string]$computername            
)            
begin{}            
process{            
<# $result = New-Object -TypeName PSObject -Property @{            
  Server = $computername            
  Status = 'Offline'            
 }  #>
 
 $result = [pscustomobject] @{
  Server = $computername
  Status = 'Offline'
 }
           
 if (Test-Connection -ComputerName $computername -Count 1 -Quiet){            
  $result.Status = 'On-line'            
 }            
 Write-Output $result            
}            
end{}            
}            


function Get-OUServers {
param (
  [Parameter(Mandatory=$true, ValueFromPipeline = $true)][array]$ous)

begin{} 
process {
    try {

$ous | % { Get-QADComputer -SearchRoot bmg.bagint.com/$_ -OSName 'Windows*Server*' } | 
  Select-Object @{n='computername'; e={$($_.Name)}} | test-computer | Sort-Object status | Format-Table -AutoSize 
    } catch {$_.exception.message;continue}
  }
end{}
}

# pass array of ous
Get-OUServers -ous usa

# can be dot sourced too
# .\get-ouServers.ps1 usa,nyc,lyn