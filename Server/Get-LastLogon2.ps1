#requires -Version 3 -Modules ActiveDirectory
workflow Get-LastLogon4
{
  param (
    [string[]]$computername,
    [string] $username
  )

  foreach -parallel ($dc in $computername) 
  {
    Get-ADUser -Identity $username -Properties lastLogon, LastLogonDate, lastLogonTimestamp -Server $dc  | 
    Select-Object -Property Name, LastLogondate,
    @{N = 'LastLogon'; E = {[datetime]::FromFileTime([int64]::Parse($_.lastlogon))}}, 
    @{N = 'LastLogonTimestamp'; E = {[datetime]::FromFileTime([int64]::Parse($_.lastlogonTimestamp))}} |
    Add-Member -MemberType NoteProperty -Name 'DomainController' -Value $dc -PassThru
  }
}

<#Get-LastLogon -computername (Get-ADDomainController -Filter * | 
  Select-Object -ExpandProperty Name) -username sconnea -ea 0 |
  Format-Table Name, LastLogonDate, LastLogon, LastLogonTimeStamp, DomainController

  $users = Get-QADUser -SearchRoot 'bmg.bagint.com/RIO/ADA/SAC' -SizeLimit 5 | Select-Object samaccountname

 foreach ($user in $users){

  Get-LastLogon -computername 'GTLSMEADS0011' -username $user
  }#>