# **********************************************************
# **********************************************************
# ***** Sony BMG Music Entertainment				   *****			
# ***** Created by: Phillip Fuentes					   *****
# ***** Date: 11/08/07								   *****
# ***** Description: Collect list of Domain Controllers*****
# **********************************************************
# **********************************************************

$erroractionpreference = "SilentlyContinue"
$a = New-Object -comobject Excel.Application
$a.visible = $True 

$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1)

$c.Cells.Item(1,1) = "Machine Name"
$c.Cells.Item(1,2) = "DnsHostName"
$c.Cells.Item(1,3) = "Site"
$c.Cells.Item(1,4) = "Domain"
$c.Cells.Item(1,5) = "GlobalCatalog"

$d = $c.UsedRange
$d.Interior.ColorIndex = 15
$d.Font.ColorIndex = 1
$d.Font.Bold = $True


$intRow = 2

$colDC = Get-DomainController
foreach ($objDC in $colDC)
{
$c.Cells.Item($intRow, 1) = $objDC.ServerName
$c.Cells.Item($intRow, 2) = $objDC.DnsHostName
$c.Cells.Item($intRow, 3) = $objDC.Site
$c.Cells.Item($intRow, 4) = $objDC.Domain

$GC = $objDC.GlobalCatalog
If($GC -like "TRUE")
{
$c.Cells.Item($intRow,5).Interior.ColorIndex = 4
$c.Cells.Item($intRow,5) = "TRUE"
}
Else
{
$c.Cells.Item($intRow,5).Interior.ColorIndex = 3
$c.Cells.Item($intRow,5) = "False"
}
$intRow = $intRow + 1
}
$d.EntireColumn.AutoFit()