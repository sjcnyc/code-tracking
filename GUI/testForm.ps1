Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'testForm.designer.ps1')
$Form1.ShowDialog()