[CmdletBinding(SupportsShouldProcess)]
 param (
$minutes = 60)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

for ($i = 0; $i -lt $minutes; $i++) {
  Start-Sleep -Seconds 60
  $Pos = [Windows.Forms.Cursor]::Position
  [Windows.Forms.Cursor]::Position = New-Object -TypeName System.Drawing.Point -ArgumentList ((($Pos.X) + 5) , $Pos.Y)
}