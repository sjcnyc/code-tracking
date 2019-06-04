
param(
	$SourceAccount,
	$DestinationAccount,
    $ComputerName
)

# Load Visual Basic assembly
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

# Load Active Directory Module
Import-Module ActiveDirectory

# Create hashtable for splatting in the Get-ADUser cmdlet
$ADUserSplat = @{
    Property = 'memberof'
}

# Checks if both accounts are provided as an argument, otherwise prompts for input
if (-not $SourceAccount) { $SourceAccount = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the name of the account to read the groups from...', 'Source Account', '') }
if (-not $DestinationAccount) { $DestinationAccount = [Microsoft.VisualBasic.Interaction]::InputBox('Enter the name of the account to set the groups to...', 'Destination Account', '') }
if ($ComputerName) {$ADUserSplat.Server = $ComputerName}

# Retrieves the group membership for both accounts, if account is not found or error is generated the object is set to $null
try { $sourcemember = get-aduser -filter {samaccountname -eq $SourceAccount} @ADUserSplat | Select-Object memberof }
catch {	$sourcemember = $null}
try { $destmember = get-aduser -filter {samaccountname -eq $DestinationAccount} @ADUserSplat | Select-Object memberof }
catch { $destmember = $null}

# Checks if accounts have group membership, if no group membership is found for either account script will exit
if ($sourcemember -eq $null) {[Microsoft.VisualBasic.Interaction]::MsgBox('Source user not found',0,'Exit Message');return}
if ($destmember -eq $null) {[Microsoft.VisualBasic.Interaction]::MsgBox('Destination user not found',0,'Exit Message');return}

# Checks for differences, if no differences are found script will prompt and exit
if (-not (compare-object $destmember.memberof $sourcemember.memberof)) {
	[Microsoft.VisualBasic.Interaction]::InputBox("No difference between $SourceAccount & $DestinationAccount groupmembership found. $DestinationAccount will not be added to any additional groups.",0,'Exit Message');return
}

# Prompt for adding user to groups, only prompt when there are changes
if (compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '=>'}) {
	$ConfirmAdd = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to add `'$($DestinationAccount)`' to the following groups:`n`n$((compare-object $destmember.memberof $sourcemember.memberof | 
	where-object {$_.sideindicator -eq '=>'} | select -expand inputobject | foreach {([regex]::split($_,'^CN=|,.+$'))[1]}) -join "`n")",4,'Please confirm the following action')
}

# Prompt for removing user from groups, only prompt when there are changes
if (compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '<='}) {
	$ConfirmRemove = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you want to remove `'$($DestinationAccount)`' from the following groups:`n`n$((compare-object $destmember.memberof $sourcemember.memberof | 
	where-object {$_.sideindicator -eq '<='} | select -expand inputobject | foreach {([regex]::split($_,'^CN=|,.+$'))[1]}) -join "`n")",4,'Please confirm the following action')
}

# If the user confirmed adding the groups to the account, the user will be added to the groups
if ($ConfirmAdd -eq 'Yes') {
	compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '=>'} | 
	Select-Object -expand inputobject | foreach {add-adgroupmember "$_" $DestinationAccount}
}

# If the user confirmed removing any groups not present on the source account, the user will be removed from the groups
if ($ConfirmRemove -eq 'Yes') {
	compare-object $destmember.memberof $sourcemember.memberof | where-object {$_.sideindicator -eq '<='} | 
	Select-Object -expand inputobject | foreach {remove-adgroupmember "$_" $DestinationAccount -Confirm:$false}
}

# Prompt after executing script
[void][Microsoft.VisualBasic.Interaction]::MsgBox('Script successfully executed',0,'Exit Message')
exit