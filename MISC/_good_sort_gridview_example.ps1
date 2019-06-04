# _gridview

PARAM([int]$Interval=30,[ScriptBlock]$ScriptBlock={(Get-Process | Select-Object PSResources,cpu -ExcludeProperty TotalProcessorTime)})

[System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms')  

# Helper function to translate the scriptblock output into a DataTable

Function out-DataTable {

  $dt = new-object Data.datatable  
  $First = $true  

  foreach ($item in $input){  
    $DR = $DT.NewRow()  
    $Item.PsObject.get_properties() | foreach {  
      if ($first) {  
        $Col =  new-object Data.DataColumn  
        $Col.ColumnName = $_.Name.ToString()  
        $DT.Columns.Add($Col)       }  
      if ($_.value -eq $null) {  
        $DR.Item($_.Name) = '[empty]'  
      }  
      elseif ($_.IsArray) {  
        $DR.Item($_.Name) =[string]::Join($_.value ,';')  
      }  
      else {  
        $DR.Item($_.Name) = $_.value  
      }
    }  
    $DT.Rows.Add($DR)  
    $First = $false  
  } 

  return @(,($dt))

}

# Make form  

$form = new-object System.Windows.Forms.form   
$form2 = new-object System.Windows.Forms.form   
$Form.text = "PowerShell Script Monitor: $ScriptBLock "   
$form.Size =  new-object System.Drawing.Size(810,410)  

# Add DataGrid

$DG = new-object windows.forms.DataGridView 
  
$DG.Dock = [System.Windows.Forms.DockStyle]::Fill 
$dg.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize 
$dg.SelectionMode = 'FullRowSelect'
$form.Controls.Add($DG)

# Build Menu    

$MS = new-object System.Windows.Forms.MenuStrip   
$Mi = new-object System.Windows.Forms.ToolStripMenuItem('&File')   

$Msi1 = new-object System.Windows.Forms.ToolStripMenuItem('&Refresh') 
$Msi1.ShortcutKeys = 0x20052
  
$msi1.add_Click({
    $col = $dg.SortedColumn
    $SortOrder = $dg.SortOrder
    $script:dt = (&$scriptBlock | out-dataTable )
    $script:DG.DataSource = $DT.psObject.baseobject
    if ("$sortOrder" -ne 'None' ) {$dg.Sort($dg.columns[($col.name)],"$SortOrder")}
    $Rows.Text = " [ Rows : $($script:dt.rows.count) ] "
})    
$Mi.DropDownItems.Add($msi1)   

$Msi2 = new-object System.Windows.Forms.ToolStripMenuItem('&Quit')   
$msi2.add_Click({$form.close()})    
$Mi.DropDownItems.Add($msi2)   

$ms.Items.Add($mi)   
$form.Controls.Add($ms) 

# statusStrip

$statusStrip = new-object System.Windows.Forms.StatusStrip

$Rows = new-object System.Windows.Forms.ToolStripStatusLabel
$Rows.BorderStyle = 'SunkenInner'
$Rows.BorderSides = 'All'
[void]$statusStrip.Items.add($Rows)

$status = new-object System.Windows.Forms.ToolStripStatusLabel
$status.BorderStyle = 'SunkenInner'
$status.BackColor = 'ButtonHighlight'
$status.BorderSides = 'All'
$Status.Text = " [ Next Refresh in : $(new-Timespan -sec $Interval) ] [ Refresh Interval : $Interval Seconds ] "
[void]$statusStrip.Items.add($status)

$Command = new-object System.Windows.Forms.ToolStripStatusLabel
$Command.Spring = $true
$Command.BorderStyle = 'SunkenInner'
$Command.BorderSides = 'All'
$Command.Text = "$ScriptBlock"
[void]$statusStrip.Items.add($Command)

$form.Controls.Add($statusStrip)

# Make Timer 

$timer = New-Object System.Windows.Forms.Timer 
if ($interval -gt 30 ) {$timer.Interval = 5000} Else {$timer.Interval = 1000}
$SecsToInterval = $interval

$timer.add_Tick({

  $SecsToInterval -= ($timer.Interval / 1000)
 
 if ( $SecsToInterval -eq 0 ) {
    $SecsToInterval = $interval
    $Command.BackColor = 'Red'
    $statusStrip.Update()
    $col = $dg.SortedColumn
    $SortOrder = $dg.SortOrder
    $script:dt = (&$scriptBlock | out-dataTable )
    $script:DG.DataSource = $DT.psObject.baseobject
    if ("$sortOrder" -ne 'None' ) {$dg.Sort($dg.columns[($col.name)],"$SortOrder")}
    $Rows.Text = " [ Rows : $($script:dt.rows.count) ] "
  }


  $Command.BackColor = 'Control'
  $Status.Text = " [ Next Refresh in : $(new-Timespan -sec $SecsToInterval) ] [ Refresh Interval : $Interval Seconds ] "
  $statusStrip.Update()

})

$timer.Enabled = $true
$timer.Start()

# show Form  

$Form.Add_Shown({
  $script:dt = (&$scriptBlock | out-dataTable )
  $script:DG.DataSource = $DT.psObject.baseobject
  $Rows.Text = " [ Rows : $($script:dt.rows.count) ] "
  $dg.AutoResizeColumns()
  $form.Activate()
}) 

$form.showdialog()