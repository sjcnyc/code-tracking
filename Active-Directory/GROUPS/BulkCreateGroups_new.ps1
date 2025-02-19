function New-SecurityGroup {
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [ValidateSet('USA-GBL', 'USA-GBL ISI SHARE', 'USA-GBL ISI-Misc', 'USA-GBL ISI-DATA', 'ISI Creative-NY', 'USA-GBL ISI-Mactech')] 
        [string[]]$OU,
        [string]$name,
        [string]$path
    )

    #import-csv 'c:\SecurityGroups.csv' | % {
    $fullname = "$($ou) $($name)"
    $description = "$($path)$($name)"
    $container = "OU=$($fullname),OU=FileShare Access,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com"
    New-QADGroup `
        -ParentContainer $container `
        -Name $fullname `
        -samAccountName $fullname `
        -GroupScope 'Global' `
        -GroupType 'Security' `
        -Description $description `

}