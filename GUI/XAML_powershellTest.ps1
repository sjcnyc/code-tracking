$inputXML = @"
<Window x:Class="XAML_Powershell_test.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Powershell XAML" Height="244" Width="440">
    <Grid>
        <Label x:Name="label" Content="ComputerName" HorizontalAlignment="Left" Margin="10,11,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="textbox" HorizontalAlignment="Left" Height="23" Margin="124,14,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="163"/>
        <Button x:Name="Button" Content="get-DiskInfo" HorizontalAlignment="Left" Margin="332,13,0,0" VerticalAlignment="Top" Width="75" RenderTransformOrigin="0.547,0.182"/>
        <ListView x:Name="listview" HorizontalAlignment="Left" Height="155" Margin="10,42,0,0" VerticalAlignment="Top" Width="410">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Drive Letter" Width="100" DisplayMemberBinding="{Binding 'Drive Letter'}"/>
                    <GridViewColumn Header="Drive Label" Width="100" DisplayMemberBinding="{Binding 'Drive Label'}"/>
                    <GridViewColumn Header="Size(MB)" Width="100" DisplayMemberBinding="{Binding 'Size(MB)'}"/>
                    <GridViewColumn Header="FreeSpace(MB)" Width="100" DisplayMemberBinding="{Binding 'FreeSpace(MB)'}"/>
                </GridView>
            </ListView.View>
        </ListView>
    </Grid>
</Window>
"@

$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
try {$Form = [Windows.Markup.XamlReader]::Load( $reader )}
catch {Write-Host 'Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed.'}
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes('//*[@Name]') | % {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

Function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) {
        Write-host 'If you need to reference this display again, run Get-FormVariables' -ForegroundColor Yellow; $global:ReadmeDisplay = $true
    }
    write-host 'Found the following interactable elements from our form' -ForegroundColor Cyan
    get-variable WPF*
}
 
Get-FormVariables
Function Get-ReadableStorage {
    param
    (
        [System.Object]
        $size
    )
    $postfixes = @( 'B', 'KB', 'MB', 'GB', 'TB', 'PB' )
    for ($i = 0; $size -ge 1024 -and $i -lt $postfixes.Length - 1; $i++) { $size = $size / 1024; }
    return '' + [System.Math]::Round($size, 2) + ' ' + $postfixes[$i];
}
 
Function Get-DiskInfo {
    param($computername = $env:COMPUTERNAME)
 
    Get-WMIObject Win32_logicaldisk -ComputerName $computername | 
        Select-Object `
    @{Name = 'ComputerName'; Ex = {$computername}}, `
    @{Name = 'Drive Letter'; Expression = {$_.DeviceID}}, `
    @{Name = 'Drive Label'; Expression = {$_.VolumeName}}, `
    @{Name = 'Size(MB)'; Expression = {Get-ReadableStorage($_.Size)}}, `
    @{Name = 'FreeSpace(MB)'; Expression = {Get-ReadableStorage($_.FreeSpace)}}
}
                                                                  
$WPFtextBox.Text = $env:COMPUTERNAME
 
$WPFbutton.Add_Click( {
        $WPFlistView.Items.Clear()
        start-sleep -Milliseconds 840
        Get-DiskInfo -computername $WPFtextBox.Text | % {$WPFlistView.AddChild($_)}
    })

#===========================================================================
# Shows the form
#===========================================================================
$Form.ShowDialog() | out-null