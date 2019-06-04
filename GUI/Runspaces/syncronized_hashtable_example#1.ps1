
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# This is the key that I needed to unlocking effective multithreading. Thank you very much Boe!
# All data that will be shared across threads will be placed into this hash table.

$SyncHash = [hashtable]::Synchronized(@{})
$ScriptBlock = `
{
	# Created the Powershell instance that will run my script block.
	$NewUser = [PowerShell]::Create().AddScript({
		Start-Sleep -Seconds 5
		$SyncHash.DataGrid.Rows.Add('New UserName','This is yet another test field.')
	})
	
	# Created a new runspace
	$NewUserRunspace = [RunspaceFactory]::CreateRunspace()
	$NewUserRunspace.ApartmentState = 'STA'
	# The command below only allowed 1 click to be executed at a time, even if you clicked the hell out of the button while it was in progress. I commented it out for the ability to have more than 1 thread created in this runspace.
	# $NewUserRunspace.ThreadOptions = "ReuseThread"
	$NewUserRunspace.Open()
	$NewUserRunspace.SessionStateProxy.SetVariable('SyncHash',$SyncHash)
	# Assigned my new Powershell Instance to the runspace I just created.
	$NewUser.Runspace = $NewUserRunspace
	# Invoked the Powershell Instance/Script.
	$NewUser.BeginInvoke()
}

$Main = New-Object Windows.Forms.Form
$Main.Width = 1024
$Main.Height = 768
$Button = New-Object Windows.Forms.Button
$Button.Location = New-Object Drawing.Point(0,708)
$Button.Size = New-Object Drawing.Size(1010,24)
$Button.Anchor = 'Left,Right,Bottom'
$Button.Text = 'Add Row (This Button is a representation of dropping a PDF account request into this window.)'
# Click this beautiful button!
$Button.Add_Click($ScriptBlock)
$Main.Controls.Add($Button)
# Since the DataGrid needed to be accessed from across multiple threads, it was created within the Synchronized Hash Table.
$SyncHash.DataGrid = New-Object System.Windows.Forms.DataGridView
$SyncHash.DataGrid.Size = New-Object Drawing.Size(1010,708)
$SyncHash.DataGrid.Anchor = 'Top,Left,Right,Bottom'
$SyncHash.DataGrid.ColumnCount = 2
$SyncHash.DataGrid.Columns[0].Name = 'UserName'
$SyncHash.DataGrid.Columns[1].Name = 'Note'
#The DataGrid is still added to the main form in the normal way, nothing has changed because of the fact that I put it in another object.
$Main.Controls.Add($SyncHash.DataGrid)
[Windows.Forms.Application]::Run($Main)