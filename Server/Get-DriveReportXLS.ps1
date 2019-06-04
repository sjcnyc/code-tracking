#Requires -version 2.0

<#
this version takes an array of computer names and creates a new
worksheet for each one.
#>

$computername = @('ny1','stmsbmewfp001','usnaspwfs01','nassbmewfp001','uslynpwfs08','uslynvwinf003','lynsbmeweb003','lynsbmebkp001')
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.office.interop.excel') | out-null

#[cmdletbinding()]
#Param([string[]]$computername=$env:computername)

#I hope it goes without saying that Excel needs to be installed
Write-Verbose 'Creating Excel application' 
$xl=New-Object -ComObject 'Excel.Application' 
$wb=$xl.Workbooks.Add()

#we'll need some constants
$xlConditionValues=[Microsoft.Office.Interop.Excel.XLConditionValueTypes]
$xlTheme=[Microsoft.Office.Interop.Excel.XLThemeColor]
$xlChart=[Microsoft.Office.Interop.Excel.XLChartType]
$xlIconSet=[Microsoft.Office.Interop.Excel.XLIconSet]
$xlDirection=[Microsoft.Office.Interop.Excel.XLDirection]

Foreach ($computer in $computername) {
    #get disk data
    Write-Verbose "Getting disk data from $computer" 
    $disks=Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter 'DriveType=3'

    Write-Verbose 'Adding Worksheet' 
    $ws=$wb.Worksheets.Add()

    $cells=$ws.Cells

    $cells.item(1,1)='Disk Drive Report'

    #define some variables to control navigation
    $row=3
    $col=1

    #insert column headings
    Write-Verbose 'Adding drive headings' 

    'Drive','SizeGB','FreespaceGB','UsedGB','%Free','%Used' | foreach {
        $cells.item($row,$col)=$_
        $cells.item($row,$col).font.bold=$True
        $col++
    }

    Write-Verbose 'Adding drive data' 
    foreach ($drive in $disks) {
        $row++
        $col=1
        $cells.item($Row,$col)=$drive.DeviceID
        $col++
        $cells.item($Row,$col)=$drive.Size/1GB
        $cells.item($Row,$col).NumberFormat='0'
        $col++
        $cells.item($Row,$col)=$drive.Freespace/1GB
        $cells.item($Row,$col).NumberFormat='0.00'
        $col++
        $cells.item($Row,$col)=($drive.Size - $drive.Freespace)/1GB
        $cells.item($Row,$col).NumberFormat='0.00'
        $col++
        $cells.item($Row,$col)=($drive.Freespace/$drive.size)
        $cells.item($Row,$col).NumberFormat='0.00%'
        $col++
        $cells.item($Row,$col)=($drive.Size - $drive.Freespace) / $drive.size
        $cells.item($Row,$col).NumberFormat='0.00%'
    }

    Write-Verbose 'Adding some style' 

    #add some style
    $range=$ws.range('A1')
    $range.Style='Title'
    #or set it like this
    $ws.Range('A3:F3').Style = 'Heading 2'

    #adjust some column widths
    Write-Verbose 'Adjusting column widths' 
    $ws.columns.item('C:C').columnwidth=15
    $ws.columns.item('D:F').columnwidth=10.5
    $ws.columns.item('B:B').EntireColumn.AutoFit() | out-null

    #add some conditional formatting
    Write-Verbose 'Adding conditional formatting' 

    #get the starting cell
    $start=$ws.range('F4')
    #get the last cell
    $Selection=$ws.Range($start,$start.End($xlDirection::xlDown))
    #add the icon set
    $Selection.FormatConditions.AddIconSetCondition() | Out-Null
    $Selection.FormatConditions.item($($Selection.FormatConditions.Count)).SetFirstPriority()
    $Selection.FormatConditions.item(1).ReverseOrder = $True
    $Selection.FormatConditions.item(1).ShowIconOnly = $False
    $Selection.FormatConditions.item(1).IconSet = $xlIconSet::xl3TrafficLights1
    $Selection.FormatConditions.item(1).IconCriteria.Item(2).Type=$xlConditionValues::xlConditionValueNumber
    $Selection.FormatConditions.item(1).IconCriteria.Item(2).Value=0.8
    $Selection.FormatConditions.item(1).IconCriteria.Item(2).Operator=7
    $Selection.FormatConditions.item(1).IconCriteria.Item(3).Type=$xlConditionValues::xlConditionValueNumber
    $Selection.FormatConditions.item(1).IconCriteria.Item(3).Value=0.9
    $Selection.FormatConditions.item(1).IconCriteria.Item(3).Operator=7
    
    #insert a graph
    Write-Verbose 'Creating a graph' 
    $chart=$ws.Shapes.AddChart().Chart
    $chart.chartType=$xlChart::xlBarClustered

    $start=$ws.range('A3')
    #get the last cell
    $Y=$ws.Range($start,$start.End($xlDirection::xlDown))
    $start=$ws.range('F3')
    #get the last cell
    $X=$ws.Range($start,$start.End($xlDirection::xlDown))

    $chartdata=$ws.Range("A$($Y.item(1).Row):A$($Y.item($Y.count).Row),F$($X.item(1).Row):F$($X.item($X.count).Row)")
    $chart.SetSourceData($chartdata)

    #add labels
    $chart.seriesCollection(1).Select() | Out-Null
    $chart.SeriesCollection(1).ApplyDataLabels() | out-Null
    #modify the chart title
    $chart.ChartTitle.Text = 'Utilization'
    Write-Verbose 'Repositioning graph' 
    $ws.shapes.item('Chart 1').top=40
    $ws.shapes.item('Chart 1').left=400

    Write-Verbose 'Renaming the worksheet'  
    #rename the worksheet
    $name=$disks[0].SystemName
    $ws.Name=$name
    #select A1
    $ws.Range('A1').Select() | Out-Null
} #foreach

#delete extra sheets
Write-Verbose 'Deleting extra worksheets'
$xl.worksheets.Item('Sheet1').Delete() | out-null
$xl.Worksheets.Item('Sheet2').Delete() | out-null
$xl.Worksheets.Item('Sheet3').Delete() | out-null

#make Excel visible 
$xl.Visible=$True

$filepath=Read-Host 'Enter a path and filename to save the file'

if ($filepath) {
    Write-Verbose "Saving file to $filepath" 
    $wb.SaveAs($filepath)
    $xl.displayAlerts=$False
    $wb.Close()
    $xl.Quit()
}

#end of script