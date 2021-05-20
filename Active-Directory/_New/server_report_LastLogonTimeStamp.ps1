<#
    Workstation Host Names
    Last Logged On User
    Last Logged On User Time
    OU Location
    OS Version (Win7, Win8.1, Win10)
    Canonical Name
    Distinguished Name
    BitLocker Key
#>

#(Get-QADComputer -ldapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' -SearchScope Subtree -SizeLimit 0 | Where-Object {$_.OSName -notmatch 'Server'}).count
#(Get-QADComputer -SearchScope Subtree -SizeLimit 0 -OSName "*Server*").count


$result = New-Object System.Collections.ArrayList

$servers = (Get-QADComputer -SearchScope Subtree -SizeLimit 0 -IncludedProperties Name, OSName, OSVersion, ParentContainer, AccountIsDisabled, LastLogonTimeStamp)

foreach ($server in $servers){

    $info = [pscustomobject]@{
        'Name'               = $server.Name.ToUpper()
        'OSName'             = $Server.OSName
        'OSVersion'          = $server.OSVersion
        'ParentContainer'    = $Server.ParentContainer
        'DistinguishedName'  = $server.DN
        #'BLKey'             = ((ActiveDirectory\Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $server.dn -Properties 'msFVE-RecoveryPassword')."msFVE-RecoveryPassword" | Out-String).Trim()
        'AccountIsDisabled'  = $server.AccountIsDisabled
        'LastLogonTimeStamp' = $server.LastLogonTimeStamp
    }

    $info

    $null = $result.Add($info)
}

$result | export-csv C:\Temp\server_report_LastLogonTimeStamp.csv -NoTypeInformation


#Get-QADUser -SearchScope Subtree -IncludeAllProperties -SizeLimit 0 | Select-Object * | Export-Csv C:\Temp\User_all_attributes.csv -NoTypeInformation