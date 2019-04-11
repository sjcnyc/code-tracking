Clear-Host
$props =@('firstname','lastname','samaccountname','mail','whencreated','accountexpires','description','employeeid','dn')
$ous =@('usa/gbl/usr/employees',
        'usa/gbl/usr/non employee users',
        'usa/gbl/usr/arcade',
        'usa/gbl/usr/loh',
        'nyc',
        'bvh/wil/usr/employees',
        'bvh/wil/usr/non employee users',
        'lyn/cla/usr/employees',
        'lyn/cla/usr/non employee users',
        'fll/laro/usr',
        'fll/laro/usr/bhill'
        )

$result=@()

foreach ($prop in $props) {

switch ($prop) 
    { 
       firstname {$result+=@{n='first name';e={$_.firstname}}} 
       lastname {$result+=@{n='Last Name';e={$_.lastname}}} 
       samaccountname {$result+=@{n='SamAccount Name';e={$_.samaccountname}}}
       mail {$result+=@{n='Email';e={$_.mail}}}
       whencreated {$result+=@{n='Account Created';e={$_.whencreated}}}
       accountexpires {$result+=@{n='Account Expires';e={$_.accountexpires}}}
       description {$result+=@{n='Description';e={$_.description}}}
       employeeid {$result+=@{n='Employee ID';e={$_.employeeid}}}
       dn {$result+=@{n='DN';e={$_.dn}}}
    }
}

$checkedou = 'bmg.bagint.com/USA'#$ous |% {"bmg.bagint.com/$($_)"}
    
$query=Get-QADUser -SearchRoot $checkedou -SizeLimit 0 -IncludeAllProperties -Enabled | Select-Object $result -Unique

write-host "Query Count: $($query.count)"

$query #| export-csv c:\temp\OUreport_$(get-date -Format d-M-yyyy).csv -notype