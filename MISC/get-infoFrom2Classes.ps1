function get-infoFrom2Classes ($comp)
{
    $os = Get-WmiObject -class win32_operatingsystem -ComputerName $comp
    $comp=Get-WmiObject -class win32_computersystem -ComputerName $comp

    # new-object supports hash tables
    New-Object psObject -Property @{
        'Build Number' = $os.buildnumber;
        'OS Name' = $os.caption;
        'Service Pack' = $os.csdversion;
        'Manufacturer' = $comp.Manufacturer;
    }
}


get-infoFrom2Classes -comp ny1 | Format-Table -auto