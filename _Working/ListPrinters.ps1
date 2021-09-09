[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#window
$window = New-Object System.Windows.Forms.Form
$window.Text = 'Select a Printer'
$window.Size = New-Object System.Drawing.Size(500, 400)
$window.StartPosition = 'CenterScreen'

#Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(340, 130)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$window.AcceptButton = $okButton

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(340, 240)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$window.CancelButton = $cancelButton

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = 'Please select a printer'

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 60)
$listBox.Size = New-Object System.Drawing.Size(260, 20)
$listBox.Height = 280

Get-Printer -ComputerName usculvwprt403 | ForEach-Object { $listBox.Items.Add($_.Name) }


$window.Controls.Add($listBox)
$window.controls.Add($label)
$window.Controls.Add($cancelButton)
$window.Controls.Add($okButton)
$result = $window.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
  $x = $listBox.SelectedItem
  $x
}
