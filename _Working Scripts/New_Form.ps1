$Button1_Click = {
	$process = get-Process
	$listbox1.items.AddRange($process.Name)
}
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'New_Form.designer.ps1')
$Form1.ShowDialog()