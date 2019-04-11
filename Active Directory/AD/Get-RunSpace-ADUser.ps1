Clear-Host

$Script:UserIdentity = Read-Host 'Enter User Identity'

# Map an existing hash table to a syncronized variable for use between threads
$ADHashTable = [HashTable]::Synchronized(@{})
$ADHashTable.ADUserInfo = $null
$ADHashTable.ADUserIdentity = $Script:UserIdentity

function Get-RunSpace-ADUser {
	
	# Create a new RunSpace
	$ADRunSpace = [RunSpaceFactory]::CreateRunSpace()
	$ADRunSpace.ApartmentState = 'STA'
	$ADRunSpace.ThreadOptions = 'ReuseThread'
	$ADRunSpace.Open()
	
	# Set Synchronized hash table variable
	$ADRunSpace.SessionStateProxy.setVariable('ADHashTable',$ADHashTable)
	
	# Custom code
	$ADPowerShell = [PowerShell]::Create()
	$ADPowerShell.Runspace = $ADRunSpace
	
	# Get the handle to properly close the runspace
	$handle = $ADPowerShell.AddScript({
		Add-PSSnapin Quest.ActiveRoles.ADManagement; 
            $ADHashTable.ADUserInfo = Get-QADUser -Identity $ADHashTable.ADUserIdentity | Select-Object name, samaccountname, email
	}).BeginInvoke()
	
	# Wait for the handle job to finish
	while (-Not $handle.IsCompleted) {
		Start-Sleep -Milliseconds 100
	}
	
	foreach( $obj in $ADHashTable.ADUserInfo ) {
		
		$obj
	}
	
	# Close the session and dispose of PowerShell object
	$ADPowerShell.EndInvoke($handle)
	$ADRunSpace.Dispose()
	
}

Get-RunSpace-ADUser