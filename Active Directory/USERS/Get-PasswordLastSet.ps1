function Get-PasswordLastSet {
  #Requires -Version 3.0 
<# 
    .SYNOPSIS
        Gets pwdLastSet property after date value 


    .DESCRIPTION 
        Gets pwdLastSet property after date value 
 
    .NOTES 
        File Name  : Get-PasswordLastSet
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/3/2014

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE
        Get-PasswordLastSet -ou usa -unit years -length 3

    .EXAMPLE
        Get-PasswordLastSet -ou usa -unit years -length 3 -export

#>
  param (
    [Parameter(Mandatory=$true)]
    [string]$ou,
    [ValidateSet('years','months','days')]
    [string]$unit,
    [int]$length,
  [switch]$export)
  
  begin{} 
  process {
    try {
      
      $QADprops = 'pwdLastSet, firstname, lastname, samaccountname, parentcontainer, IsAccountDisabled' -split','
      $results=@()
      
      switch ($unit)
      {
        years   {$pwdDate = (get-date).AddYears(-$length)}
        months  {$pwdDate = (get-date).AddMonths(-$length)}
        days    {$pwdDate = (get-date).AddDays(-$length)}
      }
      
      $QADparams = @{
				sizelimit = '0'
				pagesize  = '2000'
				dontusedefaultincludedproperties = $true
				includedproperties = $QADprops
				searchroot = $ou -split',' | ForEach-Object { "bmg.bagint.com/$($ou)" }	
			}
      
      $results = Get-QADUser @QADparams |  
      Where-Object {
        $_.pwdLastSet -lt $pwdDate
      } | 
      Select-Object pwdLastSet, firstname, lastname, samaccountname, parentcontainer, `
      @{N='AccountStatus';E={
					if ($_.AccountIsDisabled -eq 'TRUE'){
						'Disabled'
					}
					else {
						'Enabled'
					}
				}
			}
      if ($export) {  
        $results | Export-Csv (Get-RandomName -drive c:\temp -Filename PasswortLastSetReport) -NoTypeInformation -Append
      }
      else {
        $results
      }
    }
    catch {$_.exception}
  }	
}