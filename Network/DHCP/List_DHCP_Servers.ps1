# *********************************************************
# *********************************************************
# ***** Sony BMG Music Entertainment				  *****			
# ***** Created by: Phillip Fuentes					  *****
# ***** Date: 11/08/07								  *****
# ***** Description: Collect DHCP Server Information  *****
# *********************************************************
# *********************************************************

$erroractionpreference = "SilentlyContinue"
$a = New-Object -comobject Excel.Application
$a.visible = $True 

$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1)

$c.Cells.Item(1,1) = "Machine Name"
$c.Cells.Item(1,2) = "IP Address"


$d = $c.UsedRange
$d.Interior.ColorIndex = 15
$d.Font.ColorIndex = 1
$d.Font.Bold = $True


$intRow = 2

$colDC = Get-DHCPServer
foreach ($objDC in $colDC)
{
$c.Cells.Item($intRow, 1) = $objDC.ServerName
$c.Cells.Item($intRow, 2) = $objDC.Address

$intRow = $intRow + 1
}
$d.EntireColumn.AutoFit()