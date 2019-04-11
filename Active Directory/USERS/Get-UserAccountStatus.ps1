$QADprops = 
    @{N='First Name';E={$_.firstname}}, `
    @{N='Last Name';E={$_.lastname}}, `
    @{N='Sam Name';E={$_.samaccountname}}, `
    @{N='Employee ID';E={$_.employeeid}}, `
    @{N='Distinguished';E={$_.distinguishedname}}, `
    @{N='Description';E={$_.description}}, `
    @{N='Account Created';E={$_.whencreated}}, `
    @{N='Account Expires';E={$_.accountexpires}}, `
    @{N='Email Address';E={$_.mail}}

$QADparams = @{
    sizelimit = '0'
    pagesize = '2000'
    dontusedefaultincludedproperties = $true
    includedproperties = 'GivenName,sn,SamAccountName,EmployeeID,DistinguishedName,Description,WhenCreated,AccountExpires,mail'-split','
    searchroot = 'usa,nyc,lyn,nas,bvh'-split',' | % {"bmg.bagint.com/$($_)"}	
    }


function Get-UserAccountStatus 
{
  param
  (
    [System.Object]
    $status
  )
  
  if ($status -eq 'e'){$acctstatus=@{enabled=$true;}
  }
  if ($status -eq 'd'){$acctstatus=@{disabled=$true;}
  }
  
  Get-QADUser @acctstatus @QADparams |Select-Object $QADprops | Format-Table -a
}


Get-UserAccountStatus -status 'd'






