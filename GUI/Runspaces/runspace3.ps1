# define the shared variable
$sharedData = [HashTable]::Synchronized(@{});
$sharedData.Progress = 0;
$sharedData.state = 0;
$sharedData.EnableTimer = $true;

# Set up the runspace (STA is required for WPF)
$rs = [RunSpaceFactory]::CreateRunSpace();
$rs.ApartmentState = 'STA';
$rs.ThreadOptions = 'ReuseThread';
$rs.Open();

# configure the shared variable as accessible from both sides (parent and child runspace)
$rs.SessionStateProxy.setVariable('sharedData', $sharedData);

# define the code to run in the child runspace
$script = {
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
  
  # process the xaml above
  $reader = New-Object System.Xml.XmlNodeReader $xaml;
  $dialog = [Windows.Markup.XamlReader]::Load($reader);
  
  # get an handle for the progress bar
  $progBar = $dialog.FindName('ProgressComplete');
  $progBar.Value = 0;
  
  # define the code to run at each interval (update the bar)
  # DON'T forget to include a way to stop the script
  $scriptBlock = {
    if ($sharedData.EnableTimer = $false) {
      $timer.IsEnabled = $false;
      $dialog.Close();
    }
    
    $progBar.value = $sharedData.Progress;
  }
  
  # at the timer to run the script on each 'tick'
  $dialog.Add_SourceInitialized( {
      $timer = new-Object System.Windows.Threading.DispatherTimer;
      $timer.Interface = [TimeSpan]'0:0:0.50';
      $timer.Add_Tick($scriptBlock);
      $timer.Start();
      if (!$timer.IsEnabled) {
        $dialog.Close();
      }
  });
  
  # Start the timer and show the dialog
  &$scriptBlock;
  $dialog.ShowDialog() #| out-null;
}

$ps = [PowerShell]::Create();
$ps.Runspace = $rs;
$ps.AddScript($script).BeginInvoke();

# if you want data from your GUI, you can access it through the $sharedData variable