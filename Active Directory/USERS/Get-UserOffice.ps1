$somevar = @('mail', 'firstname', 'lastname', 'samaccountname', 'parentcontainer', 'Office')

$QADparams = @{
    sizelimit = '0'
    pagesize = '2000'
    dontusedefaultincludedproperties = $true
    includedproperties = $somevar
    searchroot = 'usa,nyc'-split',' | ForEach-Object { "bmg.bagint.com/$($_)" }	
    }

Get-QADUser @QADparams |  Select-Object $somevar
