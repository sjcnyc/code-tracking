Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$window = New-Object Windows.Window
$inkCanvas = New-Object Windows.Controls.InkCanvas

$window.Title = 'Scribble Pad'
$window.Content = $inkCanvas
$window.Width = 800
$window.Height = 600
$window.WindowStartupLocation = 'CenterScreen'

$inkCanvas.MinWidth = $inkCanvas.MinHeight = 100

$null = $window.ShowDialog()