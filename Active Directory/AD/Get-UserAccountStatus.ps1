$QADprops =
    @{N = 'First Name';      E = {$_.firstname}}, `
    @{N = 'Last Name';       E = {$_.lastname}}, `
    @{N = 'SamAccountName';  E = {$_.samaccountname}}, `
    @{N = 'Employee ID';     E = {$_.employeeid}}, `
    @{N = 'Distinguished';   E = {$_.distinguishedname}}, `
    @{N = 'Description';     E = {$_.description}}, `
    @{N = 'Account Created'; E = {$_.whencreated}}, `
    @{N = 'Account Expires'; E = {$_.accountexpires}}, `
    @{N = 'Email Address';   E = {$_.mail}}


$somevar = 'GivenName,sn,SamAccountName,EmployeeID,DistinguishedName,Description,WhenCreated,AccountExpires,mail' -split ','
$QADparams = @{
    sizelimit                        = '0'
    pagesize                         = '2000'
    dontusedefaultincludedproperties = $true
    includedproperties               = $somevar
    searchroot                       = 'usa,nyc,lyn,bvh,nas' -split ',' | ForEach-Object { "bmg.bagint.com/$($_)" }
}

function Get-UserAccountStatus {
    Param
    (
        [parameter(Mandatory = $false)]
        [ValidateSet('enabled', 'disabled')]
        [String[]]
        $status
    )
    # value of $acctstatus hash set by validateSet option choice
    # (e.g. -status enabled = $acctStatus= key:enabled, value:$true})
    $acctStatus = @{"$status" = $true}
    Get-QADUser @acctStatus @QADparams |Select-Object $QADprops |Format-Table -auto
}
# -status validateSet (enable or disable choices)
Get-UserAccountStatus -status disabled