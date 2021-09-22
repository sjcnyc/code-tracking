

$result = New-Object -TypeName System.Collections.ArrayList


$mbxUser = Get-Mailbox -ResultSize Unlimited -piplineVariable $mbxInfo
$mbxUser | Get-MailboxPermission |
    Where-Object {
    $_.user -ne 'NT AUTHORITYSELF' -and $_.IsInherited -eq $false
} |
    ForEach-Object -Process {

    $info = [PSCustomObject]@{
        'Identity'          = $_.Identity
        'DisplayName'       = ($mbxUser.DisplayName | Out-String).Trim()
        'UserPrincipalName' = ($mbxUser.UserPrincipalName | Out-String).Trim()
        'User'              = $_.user
        'AccessRights'      = ($_.AccessRights | Out-String).Trim()
    }
    [void]$result.Add($info)

}

$result | Export-Csv C:\Temp\mbxPermsWNS3.csv -NoTypeInformation

Get-Mailbox -ResultSize Unlimited | Where-Object {$true} -PipelineVariable mb | Get-MailboxPermission | Select-Object User, @{N = 'Displayname'; E = {$mb.DisplayName}}, Identity, @{N = 'UserPrincipalName'; E = {$mb.UserPrincipalName}}, @{N = 'AccessRights'; E = {($_.AccessRights | Out-String).Trim()}}


Get-Mailbox -ResultSize Unlimited | Where-Object { $true } -PipelineVariable mb |
    Get-MailboxPermission -PipelineVariable mbs | Where-Object { $true } -PipelineVariable mbs
    Get-ADUser -Identity $mb.DistinguishedName |
    Select-Object DisplayName, DistinguishedName, Title, @{N='UserPrincipalName';E={$mb.UserPrincipalName}}, @{N='TotalItemSize';E={$mbs.TotalItemSize}}



Get-Msoluser -userprincipalname $mailbox |
    Where-Object { $true } -PipelineVariable msol |
    Add-MsolGroupMember -groupObjectId xxxxx -groupmembertype 'User' -groupmemberObjectId $msol.ObjectId

