Function Get-MachineInfo {
  $servers = $inputbox.Lines
  $hash = [hashtable]::Synchronized(@{})
  $hash.Host = $Host
  foreach ($server in $servers) {
    $hash.Server = $server
    if (Test-Connection $hash.server -count 2) {
      $runspace = [RunspaceFactory]::CreateRunspace()
      $runspace.Open()
      $runspace.SessionStateProxy.SetVariable('Hash',$hash)
      $powershell = [powershell]::Create()
      $powershell.Runspace = $runspace
      $powershell.AddScript({
          $OS = Get-WmiObject win32_operatingsystem -computername $hash.Server
          $Machine = Get-WmiObject win32_computersystem -ComputerName $hash.Server
          $Bios = Get-WmiObject win32_bios -ComputerName $hash.Server
          $LBtime=$os.ConvertToDateTime($os.lastbootuptime)
          [TimeSpan]$uptimes=New-Timespan $LBtime $(get-date)
          $uptime="$($uptimes.days) Days, $($uptimes.hours) Hours, $($uptimes.minutes) Minutes, $($uptimes.seconds) Seconds"
          $hash.Machine = $OS.Csname
          $hash.OperatingSystem = $OS.Caption
          $hash.ServicePack = $OS.csdversion
          $hash.Architecture = $OS.OSArchitecture
          $hash.Domain = $Machine.domain
          $hash.PhysicalMemory = ($machine.totalphysicalmemory/1GB)
          $hash.Manufacturer = $bios.manufacturer
          $hash.Model = $machine.model
          $hash.Version = $bios.version
          $hash.Uptime = $uptime
          #$hash.host.ui.writeverboseline(“$($hash.Machine), $($hash.OperatingSystem), $($hash.ServicePack), $($hash.FQDN), $($hash.Domain), $($hash.PhysicalMemory), $($hash.Manufacturer), $($hash.Model), $($hash.Version), $($hash.Uptime)”)
      }) | Out-Null
      $handle = $powershell.BeginInvoke()
      while (-not $handle.IsCompleted) {Start-Sleep -Milliseconds 100}
      $DataGrid.Rows.Add("$($hash.Machine)", "$($hash.OperatingSystem)", "$($hash.ServicePack)", "$($hash.Architecture)", "$($hash.Domain)", "$($hash.PhysicalMemory) GB",
      "$($hash.Manufacturer)", "$($hash.Model)", "$($hash.Version)", "$($hash.Uptime)")
      $powershell.EndInvoke($handle)
      $runspace.Close()
      $powershell.Dispose()
    } else {$DataGrid.Rows.Add("$($hash.Server): Unreachable" ); clear-host}
  }
}
#………………..This is the GUI Section……………………………………………………….#
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void] [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')

$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(1035,459)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = 'centerscreen'
$form.BackColor = 'Chocolate'

$inputbox = New-Object System.Windows.Forms.RichTextBox
$inputbox.Location = New-Object System.Drawing.Size(12,29)
$inputbox.Size = New-Object System.Drawing.Size(269,339)
$inputbox.BorderStyle = 'NONE'
$inputbox.MultiLine = $true
#$inputbox.WordWrap = $true
$inputbox.Font = New-Object System.Drawing.Font('segoe UI',9)

$Inlabel = New-Object System.Windows.Forms.Label
$Inlabel.Location = New-Object System.Drawing.Size(9,9)
$Inlabel.Size = New-Object System.Drawing.Size(193,17)
$Inlabel.Font = New-Object System.Drawing.Font('segoe UI',9.75,[System.Drawing.FontStyle]::Underline)
$Inlabel.Text = 'Please input server names.'
$Inlabel.ForeColor = 'Control'

$Outlabel = New-Object System.Windows.Forms.Label
$Outlabel.Location = New-Object System.Drawing.Size(294,9)
$Outlabel.Size = New-Object System.Drawing.Size(141,17)
$Outlabel.Font = New-Object System.Drawing.Font('segoe UI',9.75,[System.Drawing.FontStyle]::Underline)
$Outlabel.Text = 'Please see output here.'
$Outlabel.ForeColor = 'Control'

$Script:DataGrid = New-Object System.Windows.Forms.DataGridView
$DataGrid.Location = New-Object System.Drawing.Size(297,29)
$DataGrid.Size = New-Object System.Drawing.Size(719,339)
$DataGrid.BorderStyle = 'NONE'
$DataGrid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font('segoe UI',9.25)
$DataGrid.DefaultCellStyle.Font = New-Object System.Drawing.Font('segoe UI',9.25)
$DataGrid.AllowUserToAddRows = $false
$DataGrid.RowHeadersVisible = $false
$DataGrid.ColumnCount = 10
$DataGrid.Columns[0].Name = 'Machine'
$DataGrid.Columns[1].Name = 'OperatingSystem'
$DataGrid.Columns[2].Name = 'ServicePack'
$DataGrid.Columns[3].Name = 'Architecture'
$DataGrid.Columns[4].Name = 'Domain'
$DataGrid.Columns[5].Name = 'PhysicalMemory'
$DataGrid.Columns[6].Name = 'Manufacturer'
$DataGrid.Columns[7].Name = 'Model'
$DataGrid.Columns[8].Name = 'Version'
$DataGrid.Columns[9].Name = 'Uptime'
$DataGrid.AutoResizeColumns()
#$DataGrid.BackgroundColor = 'Window'

$Okbutton = New-Object System.Windows.Forms.Button
$Okbutton.Location = New-Object System.Drawing.Size(12,386)
$Okbutton.Size = New-Object System.Drawing.Size(75,23)
$Okbutton.Text = 'OK'
$Okbutton.BackColor = 'LightGray'
$Okbutton.UseVisualStyleBackColor = $true
$Okbutton.Font = New-Object System.Drawing.Font('segoe UI',9)
$Okbutton.Add_Click({Get-MachineInfo})

$Clearbutton = New-Object System.Windows.Forms.Button
$Clearbutton.Location = New-Object System.Drawing.Size(159,386)
$Clearbutton.Size = New-Object System.Drawing.Size(75,23)
$Clearbutton.Text = 'Clear'
$Clearbutton.BackColor = 'LightGray'
$Clearbutton.UseVisualStyleBackColor = $true
$Clearbutton.Font = New-Object System.Drawing.Font('segoe UI',9)
$Clearbutton.Add_Click({$inputbox.Clear()})

$Savebutton = New-Object System.Windows.Forms.Button
$Savebutton.Location = New-Object System.Drawing.Size(467,386)
$Savebutton.Size = New-Object System.Drawing.Size(75,23)
$Savebutton.Text = 'Export-CSV'
$Savebutton.BackColor = 'LightGray'
$Savebutton.UseVisualStyleBackColor = $true
$Savebutton.Font = New-Object System.Drawing.Font('segoe UI',9)

$Exitbutton = New-Object System.Windows.Forms.Button
$Exitbutton.Location = New-Object System.Drawing.Size(716,386)
$Exitbutton.Size = New-Object System.Drawing.Size(75,23)
$Exitbutton.Text = 'Exit'
$Exitbutton.BackColor = 'LightGray'
$Exitbutton.UseVisualStyleBackColor = $true
$Exitbutton.Font = New-Object System.Drawing.Font('segoe UI',9)
$Exitbutton.add_click({$form.Close()})
#…………………………………………………………………………..#
$form.Controls.Add($inputbox)
$form.Controls.Add($Inlabel)
$form.Controls.Add($Outlabel)
$form.Controls.Add($DataGrid)
$form.Controls.Add($Okbutton)
$form.Controls.Add($Clearbutton)
$form.Controls.Add($Savebutton)
$form.Controls.Add($Exitbutton)
$form.ShowDialog()
#…………………………….End of Script………………………………#

