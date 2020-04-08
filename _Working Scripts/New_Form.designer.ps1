$Form1 = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$Button1 = $null
[System.Windows.Forms.ListBox]$ListBox1 = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'New_Form.resources.ps1')
$Button1 = (New-Object -TypeName System.Windows.Forms.Button)
$ListBox1 = (New-Object -TypeName System.Windows.Forms.ListBox)
$Form1.SuspendLayout()
#
#Button1
#
$Button1.Image = ([System.Drawing.Image]$resources.'Button1.Image')
$Button1.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$Button1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]563,[System.Int32]802))
$Button1.Name = [System.String]'Button1'
$Button1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$Button1.TabIndex = [System.Int32]0
$Button1.Text = [System.String]'Button1'
$Button1.UseCompatibleTextRendering = $true
$Button1.UseVisualStyleBackColor = $true
$Button1.add_Click($Button1_Click)
$Form1.ResumeLayout($false)
Add-Member -InputObject $Form1 -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name Button1 -Value $Button1 -MemberType NoteProperty
Add-Member -InputObject $Form1 -Name ListBox1 -Value $ListBox1 -MemberType NoteProperty
}
. InitializeComponent
