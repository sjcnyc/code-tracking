Add-Type -AssemblyName System.Windows.Forms

[System.Windows.Forms.Application]::EnableVisualStyles()

# Global variables

$GH = [hashtable]::Synchronized(@{ })

$GH.FolderPath = 'C:\Users\sjcny\Dropbox'
$GH.CurrentFolderPath = $GH.FolderPath
$GH.FileMask = @('*.txt', '*.csv')

# windows form

$form = New-Object System.Windows.Forms.Form 
$form.Visible = $false
[void]$form.SuspendLayout()
$form.Text = "File Selection"
$form.ClientSize = New-Object System.Drawing.Size(320, 430) 
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# tab control

$CTRL_TabCtrl = New-Object System.Windows.Forms.TabControl
$CTRL_TabCtrl.Location = New-Object System.Drawing.Point(5, 5)
$CTRL_TabCtrl.Size = New-Object System.Drawing.Size(310, 420)
[void]$form.Controls.Add($CTRL_TabCtrl)

$CTRL_Tab1 = New-Object System.Windows.Forms.TabPage
$CTRL_Tab1.AutoSize = $true
$CTRL_Tab1.Text = 'Main'
$CTRL_Tab1.TabIndex = 1
[void]$CTRL_TabCtrl.Controls.Add($CTRL_Tab1)

# list folder

$CTRL_label10 = New-Object System.Windows.Forms.Label
$CTRL_label10.Location = New-Object System.Drawing.Point(10, 10) 
$CTRL_label10.Size = New-Object System.Drawing.Size(260, 20) 
$CTRL_label10.Name = 'Label10'
$CTRL_label10.Text = 'Please select a folder:'
[void]$CTRL_Tab1.Controls.Add($CTRL_label10) 

$CTRL_ListFolder = New-Object System.Windows.Forms.Listbox
$CTRL_ListFolder.Location = New-Object System.Drawing.Point(10, 30)
$CTRL_ListFolder.Size = New-Object System.Drawing.Size(280, 60) 
$CTRL_ListFolder.SelectionMode = [System.Windows.Forms.SelectionMode]::One
$CTRL_ListFolder.Items.AddRange( (Get-ChildItem -Path $GH.CurrentFolderPath -Directory).Name  )
$CTRL_ListFolder.Enabled = $true
$CTRL_ListFolder.Add_MouseDoubleClick( { 
    $listFolder_innerevent = $true
    if ( $CTRL_ListFolder.SelectedItem -eq '..' ) {
      $GH.CurrentFolderPath = $GH.CurrentFolderPath.Substring( 0, $GH.CurrentFolderPath.LastIndexOf( '\' ) )
      [void]$CTRL_ListFolder.Items.Clear()
      if ( $GH.CurrentFolderPath.Length -gt $GH.FolderPath.Length ) {
        [void]$CTRL_ListFolder.Items.Add( '..' )
      }
      $CTRL_ListFolder.Items.AddRange( (Get-ChildItem -Path $GH.CurrentFolderPath -Directory).Name  )

      [void]$CTRL_CheckListBox.Items.Clear()
      $files = (Get-ChildItem -Path ($GH.CurrentFolderPath + '\*') -Include $GH.FileMask -File ).Name
      if ( $files ) {
        [void]$CTRL_CheckListBox.Items.AddRange( $files )
      }
    }
    else {
      if ( (Get-ChildItem -Path ($GH.CurrentFolderPath + '\' + $CTRL_ListFolder.SelectedItem) -Directory).Name ) {
        $GH.CurrentFolderPath += '\' + $CTRL_ListFolder.SelectedItem
        [void]$CTRL_ListFolder.Items.Clear()
        [void]$CTRL_ListFolder.Items.Add( '..' )
        [void]$CTRL_ListFolder.Items.AddRange( (Get-ChildItem -Path $GH.CurrentFolderPath -Directory).Name )

        [void]$CTRL_CheckListBox.Items.Clear()
        $files = (Get-ChildItem -Path ($GH.CurrentFolderPath + '\*') -Include $GH.FileMask -File ).Name
        if ( $files ) {
          [void]$CTRL_CheckListBox.Items.AddRange( $files )
        }
      }
    }
  } )
[void]$CTRL_Tab1.Controls.Add($CTRL_ListFolder) 

# list folder with check boxes for files

$CTRL_label12 = New-Object System.Windows.Forms.Label
$CTRL_label12.Location = New-Object System.Drawing.Point(10, 100) 
$CTRL_label12.Size = New-Object System.Drawing.Size(260, 20) 
$CTRL_label12.Name = 'Label12'
$CTRL_label12.Text = 'Files found:'
[void]$CTRL_Tab1.Controls.Add($CTRL_label12) 


$CTRL_CheckListBox = New-Object System.Windows.Forms.CheckedListbox
$CTRL_CheckListBox.Location = New-Object System.Drawing.Point(10, 120)
$CTRL_CheckListBox.Size = New-Object System.Drawing.Size(280, 230) 
$CTRL_CheckListBox.CheckOnClick = $true
$CTRL_CheckListBox.Enabled = $true
$files = (Get-ChildItem -Path ($GH.CurrentFolderPath + '\*') -Include $GH.FileMask -File ).Name
if ( $files ) {
  [void]$CTRL_CheckListBox.Items.AddRange( $files )
}
[void]$CTRL_Tab1.Controls.Add($CTRL_CheckListBox) 

$CTRL_OKButton1 = New-Object System.Windows.Forms.Button
$CTRL_OKButton1.Location = New-Object System.Drawing.Point(70, 365)
$CTRL_OKButton1.Size = New-Object System.Drawing.Size(75, 23)
$CTRL_OKButton1.Text = 'OK'
$CTRL_OKButton1.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $CTRL_OKButton1
[void]$CTRL_Tab1.Controls.Add($CTRL_OKButton1)

$CTRL_CancelButton1 = New-Object System.Windows.Forms.Button
$CTRL_CancelButton1.Location = New-Object System.Drawing.Point(150, 365)
$CTRL_CancelButton1.Size = New-Object System.Drawing.Size(75, 23)
$CTRL_CancelButton1.Text = 'Cancel'
$CTRL_CancelButton1.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CTRL_CancelButton1
[void]$CTRL_Tab1.Controls.Add($CTRL_CancelButton1)

[void]$form.ResumeLayout()

$userInput = $form.ShowDialog()

if ($userInput -eq [System.Windows.Forms.DialogResult]::OK) {
  # User clicked OK Button
}