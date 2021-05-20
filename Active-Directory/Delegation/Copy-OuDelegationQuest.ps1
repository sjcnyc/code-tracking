Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction silentlycontinue

$sourceroot = "OU=Managed Objects,DC=yourdomain,DC=local"
$targetroot = "OU=New,DC=yourdomain,DC=local"

Get-QADObject -Type organizationalunit -SearchRoot $sourceroot -SearchScope subtree |
    Where-Object {$_.dn -ne $sourceroot} |
    ForEach-Object {
    Add-Member -InputObject $_ -MemberType noteproperty -Name level -Value ($_.dn -split ",").count -PassThru
} |
    Sort-Object -Property level |
    ForEach-Object {
    $parent = if ($_.dn -match "[^,]+,(.*)") {$matches[1]}
    $parent = $parent -replace ([regex]::escape($sourceroot)), $targetroot
    New-QADObject -Type organizationalunit -Name $_.name -ParentContainer $parent
}