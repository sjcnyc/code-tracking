Function ConvertFrom-EpochTime {
    [CmdLetBinding()]
    [Alias('FromUnix','ConvertFrom-UnixTime')]
    Param (
        [Parameter()]
            [String]$EpochTime
    ) 
    
    Process {
        ([DateTime]'1/1/1970').AddSeconds($EpochTime).ToString('dddd, MMMM dd, yyy')
    }
} # Function ConvertFrom-EpochTime

$UnixTimes = '1554472172','1554372548','1554272560'

ForEach ($Time in $UnixTimes) {
    ConvertFrom-EpochTime -EpochTime $Time
}