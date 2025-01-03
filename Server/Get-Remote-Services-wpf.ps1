Add-Type -AssemblyName presentationframework

[xml]$XAML = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Remote Services Tool" Height="518" Width="790">
    <Grid>
        <DataGrid AutoGenerateColumns="False" Height="406" HorizontalAlignment="Stretch" Margin="0,32,0,0" Name="DataGrid1" VerticalAlignment="Top" Width="740" ItemsSource="{Binding}" SelectionUnit="Cell">
            <DataGrid.Columns>
                <DataGridCheckBoxColumn Binding="{Binding Path=IsChecked}"/>
                <DataGridTextColumn Binding="{Binding Path=Name}" Header="Name" />
                <DataGridTemplateColumn Header="Status">
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate >
                            <Border x:Name="brdBroder" VerticalAlignment="Stretch" Margin="1">
                                <TextBlock Text="{Binding Status}" Margin="3,1" x:Name="txtTextBlock"/>
                            </Border>
                            <DataTemplate.Triggers>
                                <DataTrigger Binding="{Binding Status}" Value="Running">
                                    <Setter TargetName="brdBroder" Property="Background" Value="Green"/>
                                    <Setter TargetName="txtTextBlock" Property="Foreground" Value="White"/>
                                </DataTrigger>
                                <DataTrigger Binding="{Binding Status}" Value="Stopped">
                                    <Setter TargetName="brdBroder" Property="Background" Value="Red"/>
                                    <Setter TargetName="txtTextBlock" Property="Foreground" Value="White"/>
                                </DataTrigger>
                            </DataTemplate.Triggers>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTextColumn Binding="{Binding Path=DisplayName}" Header="DisplayName" Width="*"/>
            </DataGrid.Columns>
            <DataGrid.CellStyle>
                <Style TargetType="DataGridCell" >
                    <Setter Property="Background" Value="{Binding Color}"/>
                </Style>
            </DataGrid.CellStyle>
        </DataGrid>
        <Button Content="Connect" Height="23" HorizontalAlignment="Left" Margin="278,4,0,0" Name="Btn_Connect" VerticalAlignment="Top" Width="75" />
        <Label Content="Computer Name:" Height="28" HorizontalAlignment="Left" Margin="12,0,0,0" Name="Label1" VerticalAlignment="Top" />
        <TextBox Height="23" HorizontalAlignment="Left" Margin="119,5,0,0" Name="Txt_ComputerName" VerticalAlignment="Top" Width="153" />
        <Button Content="Start" Height="23" HorizontalAlignment="Left" Margin="680,444,0,0" Name="Btn_Start" VerticalAlignment="Top" Width="75" />
        <Button Content="Stop" Height="23" HorizontalAlignment="Left" Margin="596,444,0,0" Name="Btn_Stop" VerticalAlignment="Top" Width="75" />
        <Button Content="Restart" Height="23" HorizontalAlignment="Left" Margin="513,444,0,0" Name="Btn_Restart" VerticalAlignment="Top" Width="75" />
        <Label Content="" Height="28" HorizontalAlignment="Left" Margin="12,446,0,0" Name="Lbl_Error" VerticalAlignment="Top" Width="485"  FontWeight="Bold"/>
    </Grid>
</Window>
'@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
$Form=[Windows.Markup.XamlReader]::Load( $reader )

#Find objects
$DataGrid1 = $form.FindName('DataGrid1')
$btn_connect = $form.FindName('Btn_Connect')
$btn_start = $form.FindName('Btn_Start')
$btn_restart = $form.FindName('Btn_Restart')
$btn_stop = $form.FindName('Btn_Stop')
$txt_compName = $form.FindName('Txt_ComputerName')
$lbl_err = $form.FindName('Lbl_Error')

function FillListView($Computer)
{
    $script:emptyarray = New-Object System.Collections.ArrayList   
    $Services = Get-Service -ComputerName $Computer -ErrorAction stop

    foreach ($item in $Services)
    {
        Write-Host $item.name
        $tmpObject = Select-Object -InputObject '' IsChecked,Name, Status, DisplayName,color
        $tmpObject.IsChecked = $false
        $tmpObject.Name = $item.Name
        $tmpObject.Status = $item.Status
        $tmpObject.DisplayName = $item.DisplayName
        $tmpObject.Color = 'white'
        $script:emptyarray += $tmpObject
    }
   $DataGrid1.ItemsSource = $emptyarray    
}

$btn_connect.Add_Click({

    if(Test-Connection -ComputerName $txt_compName.text ){
        try{
            $lbl_err.Content = '' 
            FillListView -Computer $txt_compName.text
        }        
        Catch{ $lbl_err.Content = 'Failed to fill DataGrid' }        
    }
    else{    
        $lbl_err.Content = 'Computer may be offline, or name misspelled'
    }
})

$btn_start.Add_Click({
       foreach($AddedItem in $script:emptyarray)
        {
            if($AddedItem.IsChecked)
            {
                $Service = $AddedItem.Name
                try{              
                    Start-Service -InputObject $(Get-Service -Computer $txt_compName.text -Name $Service) -PassThru
                }
                catch{ $lbl_err.Content = 'Failed to Start Service(s)' }                
                Start-Sleep 3                
                FillListView -Computer $txt_compName.text
            }
        }        
})

$btn_restart.Add_Click({
       foreach($AddedItem in $script:emptyarray)
        {
            if($AddedItem.IsChecked)
            {
                $Service = $AddedItem.Name
                Try{
                    Restart-Service -InputObject $(Get-Service -Computer $txt_compName.text -Name $Service) -PassThru
                }
                Catch{ $lbl_err.Content = 'Failed to Restart Service(s)' }
                Start-Sleep 3                
                FillListView -Computer $txt_compName.text
            }
        }        
})

$btn_stop.Add_Click({
       foreach($AddedItem in $script:emptyarray)
        {
            if($AddedItem.IsChecked)
            {
                $Service = $AddedItem.Name
                Try{
                    Stop-Service -InputObject $(Get-Service -Computer $txt_compName.text -Name $Service) -PassThru
                }
                Catch{ $lbl_err.Content = 'Failed to Stop Service(s)' }                             
                Start-Sleep 3                
                FillListView -Computer $txt_compName.text 
            }
        }        
})

$Form.ShowDialog() | out-null