#servers=get-content C:\temp\serverlist.txt 

$servers = Get-QADComputer -SearchRoot 'bmg.bagint.com/USA/GBL/SRV' | Select-Object Name
 
$excel=New-Object -ComObject 'Excel.Application' 
$wb=$excel.workbooks.add() 
$ws=$wb.activesheet 
$cells=$ws.cells 
$excel.visible=$True 
 
$row=1 
$col=1 
 
'Server name', 'Description', 'Active ILO license', 'IP', 'Subnetmask', 'ILO name', 'Gateway IP', 'License key', 'URL' | foreach { 
    $cells.item($row,$col)=$_ 
    $cells.item($row,$col).font.bold=$True 
    $col++ 
    } 
 
foreach ($server in $servers) { 
    if(Test-Connection -Cn $server.Name -BufferSize 16 -Count 1 -ea 0) { 
        $ilo=get-wmiobject -class hp_managementprocessor -computername $server.Name -namespace root\HPQ 
        if ($ilo -eq $Null) { 
            $row++ 
            $col=1 
            $cells.item($row,$col)=$server.Name 
            $cells.item($row,$col).interior.colorindex = 6 
            $col++ 
            $cells.item($row,$col)='No ILO, most likely a virtual machine' 
            $cells.item($row,$col).interior.colorindex = 6 
            continue 
            } 
        $row++ 
        $col=1 
        $cells.item($row,$col)=$server.Name 
        $col++ 
        $cells.item($row,$col)=$ilo.Description 
        $col++ 
        switch ($ilo.ActiveLicense) { 
            1 {$cells.item($row,$col)=$ilo.ActiveLicense 
            $cells.item($row,$col).interior.colorindex = 3 
            $cells.item($row,1).interior.colorindex = 3 
            $cells.item($row,2).interior.colorindex = 3 
            } 
            2 {$cells.item($row,$col)=$ilo.ActiveLicense 
            $cells.item($row,$col).interior.colorindex = 4 
            $cells.item($row,1).interior.colorindex = 4 
            $cells.item($row,2).interior.colorindex = 4 
            } 
            3 {$cells.item($row,$col)=$ilo.ActiveLicense  
            $cells.item($row,$col).interior.colorindex = 4 
            $cells.item($row,1).interior.colorindex = 4 
            $cells.item($row,2).interior.colorindex = 4 
            } 
            4 {$cells.item($row,$col)=$ilo.ActiveLicense  
            $cells.item($row,$col).interior.colorindex = 4 
            $cells.item($row,1).interior.colorindex = 4 
            $cells.item($row,2).interior.colorindex = 4 
            } 
            5 {$cells.item($row,$col)=$ilo.ActiveLicense  
            $cells.item($row,$col).interior.colorindex = 4 
            $cells.item($row,1).interior.colorindex = 4 
            $cells.item($row,2).interior.colorindex = 4 
            } 
            default {$cells.item($row,$col)=$ilo.ActiveLicense 
            $cells.item($row,$col).interior.colorindex = 6 
            } 
        } 
        $col++ 
        $cells.item($row,$col)=$ilo.ipaddress 
        $col++ 
        $cells.item($row,$col)=$ilo.ipv4subnetmask 
        $col++ 
        $cells.item($row,$col)=$ilo.hostname 
        $col++ 
        $cells.item($row,$col)=$ilo.GatewayIPAddress 
        $col++ 
        $cells.item($row,$col)=$ilo.LicenseKey 
        $col++ 
        $cells.item($row,$col)=$ilo.URL 
        } Else { 
            $row++ 
            $col=1 
            $cells.item($row,$col)=$server.Name 
            $cells.item($row,$col).interior.colorindex = 3 
            $col++ 
            $cells.item($row,$col)='Offline' 
            $cells.item($row,$col).interior.colorindex = 3 
            } 
} 
 
# $wb.SaveAs("C:\temp\ILOinformation.xls", 1)