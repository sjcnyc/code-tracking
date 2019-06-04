$syncHash = [hashtable]::Synchronized(@{})
$syncHash.Progress = 0;
$syncHash.state = 0;
$syncHash.EnableTimer = $true;
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = 'STA'
$newRunspace.ThreadOptions = 'ReuseThread'          
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable('syncHash',$syncHash)          
$psCmd = [PowerShell]::Create().AddScript({ 
    
    add-Type -assembly PresentationFramework;
    add-Type -assembly PresentationCore;
    add-Type -assembly WindowsBase;  
    
    [xml]$xaml = @"
<Window
  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
  MaxHeight="100" MinHeight="100" Height="100" 
  MaxWidth="320" MinWidth="320" Width="320" 
  WindowStyle="ToolWindow">

<Canvas Grid.Row="1">
  <TextBlock Name="ProgressText" Canvas.Top="10" Canvas.Left="20">Hello world</TextBlock>
  <ProgressBar Name="ProgressComplete" Canvas.Top="30" Canvas.Left="20" Width="260" Height="20" HorizontalAlignment="Center" Value="20" />
</Canvas>

</Window>
"@
    
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    $syncHash.progressbar = $syncHash.window.FindName('ProgressComplete')
    $syncHash.progressbar.value = 0;
    
    $scriptBlock = {
      if ($syncHash.EnableTimer = $false) {
        $timer.IsEnabled = $false;
        $dialog.Close();
      }
      $syncHash.progressbar.performstep()
      $syncHash.progressbar.value = $syncHash.Progress;
    }
    
    $dialog.Add_SourceInitialized( {
        $timer = new-Object System.Windows.Threading.DispatherTimer;
        $timer.Interface = [TimeSpan]'0:0:0.50';
        $timer.Add_Tick($scriptBlock);
        $timer.Start();
        if (!$timer.IsEnabled) {
          $dialog.Close();
        }
    });
    
    &$scriptBlock;
    
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})


$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()





Function Update-Window {
  Param (
    $Title,
    $color,
    $Content,
    [switch]$AppendContent
  )
  $syncHash.textbox.Dispatcher.invoke([action]{
      $syncHash.Window.Title = $title
      If ($PSBoundParameters['AppendContent']) {
        $syncHash.TextBox.AppendText($Content)
      } Else {
        $syncHash.TextBox.Text = $Content
      }
    },
  'Normal')
  if ($color){
    $syncHash.Window.Dispatcher.invoke(
      [action]{$syncHash.Window.Background= $color},
      'Normal'
    )
  }
}


Update-Window -Title ('Services on {0}' -f $Env:Computername) `
              -Content ( Get-Service | Out-String ) -color red

             


