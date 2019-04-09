Get-WinEvent -FilterHashtable @{Logname='System';ID=7001,7002,3261,1501}| Select-Object MachineName, ID,@{l='Category';e={Switch($_.ID){
    "7001" {"Logon"}
    "7002" {"Logoff"}
    "3261" {"JoinToWorkgroup"}
    "1501" {"GPO"}
    }
}},@{label='Time Created';expression={$_.TimeCreated.ToString("yyyy-M-d HH:mm:ss")}},Message | Format-Table -autosize