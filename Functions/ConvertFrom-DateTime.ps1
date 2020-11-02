Function ConvertFrom-DateTime () {
    <#
.SYNOPSIS
    Converts a datetime into a datetime represented in a different format.
.DESCRIPTION
    Converts a datetime into a datetime represented in a different format. All datetime output is in local timezone.
    If you wish the output to be in UTC timezone include the -UTC parameter.
.PARAMETER DateTime
    The date that you want to be converted. Can be input from the pipeline.
.PARAMETER DMTF
    A switch parameter to display in DMTF format. Default parameter set.

    DmtfDateTime is of the form "yyyymmddHHMMSS.ffffff+UUU"

    Where
        yyyy    is the 4 digit year
        mm      is the 2 digit month
        dd      is the 2 digit day of the month
        HH      is the 2 digit in 24 hour format (00-23, 1 pm = 13)
        MM      is the 2 digit minute (00-59)
        SS      is the 2 digit second (00-59)
        ffffff  is the 6 digit microsecond
        +       is a plus or minus to indicate offset from UTC
        UUU     is the 3 digit number of minutes offset from UTC (000-720)
.PARAMETER Unix
    Converts a datetime to a UnixEpoch which is the number of seconds since '1/1/1970 12:00:00 AM UTC'
.PARAMETER FileTime
    Converts a large integer filetime [int64] into a datetime string. There is a special value that returns a value of "Never". Returns a [datetime] in Universal Time (UTC)

    Filetimes are expressed in Ticks. Ticks can range from 0 - 2650467743999999999. Translating these into dates you get
                      0 = Monday, January 01, 1601 12:00:00.00000 AM
    2650467743999999999 = Friday, December 31, 9999 11:59:59.99999 PM
.PARAMETER ICSDateTime
    IcsDateTime is of the form "yyyymmddTHHMMSSZ"

    Where
        yyyy    is the 4 digit year
        mm      is the 2 digit month
        dd      is the 2 digit day of the month
        HH      is the 2 digit in 24 hour format (00-23, 1 pm = 13)
        MM      is the 2 digit minute (00-59)
        SS      is the 2 digit second (00-59)
        T       is the letter T
        Z       is an optional suffix indicating UTC or Zulu time

    If the final character is NOT a Z then the time is local time.
.PARAMETER Format
    See help for Get-Date and the -Format parameter. This duplicates that capability.
.PARAMETER IncludeOriginal
    Switch to enable the original datetime to appear in the output.
.PARAMETER UTC
    Forces the output to be in the UTC timezone. Alias of this parameter is 'Zulu'
.EXAMPLE
    ConvertFrom-DateTime -DateTime '1/28/1986 11:39' -FileTime -IncludeOriginal

    DateTime                        FileTime
    --------                        --------
    1/28/1986 11:39:00 AM 121517879400000000
.EXAMPLE
    ConvertFrom-DateTime -DateTime '1/25/2018 8:34:31 AM' -DMTF -IncludeOriginal

    Assuming a timezone of "Eastern Time" and a culture of "en-US" this would return the string

    20180125083431.000000-300
.EXAMPLE
    ConvertFrom-DateTime -DateTime '1/25/2018 8:34:31 AM' -DMTF -IncludeOriginal

    Assuming your current timezone is EST then the output would be:
    DateTime             DMTF
    --------             ----
    1/25/2018 8:34:31 AM 20180125083431.000000-300
.EXAMPLE
    ConvertFrom-DateTime -DateTime '1/25/2018 8:34:31 AM' -DMTF -UTC

    Assuming your current timezone is EST then the output would be:
    20180125133431.000000+000
.EXAMPLE
    "3/15/2018 12:00:00 PM" | ConvertFrom-DateTime -UTC

    Assuming a timezone of "Eastern Time" and a culture of "en-US" this would return the string
    20180315160000.000000+000
.NOTES
    Info:       For further information on DMTF time formats see https://docs.microsoft.com/en-us/windows/desktop/wmisdk/cim-datetime
#>

    #region parameter
    [CmdletBinding(DefaultParameterSetName = 'DMTF')]
    [OutputType('string')]
    Param
    (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'DMTF')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'Unix')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'FileTime')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'ICSDateTime')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0, ParameterSetName = 'Format')]
        [Alias('Date')]
        [datetime[]] $DateTime,

        [Parameter(ParameterSetName = 'DMTF')]
        [switch] $DMTF,

        [Parameter(ParameterSetName = 'Unix')]
        [switch] $Unix,

        [Parameter(ParameterSetName = 'FileTime')]
        [switch] $FileTime,

        [Parameter(ParameterSetName = 'ICSDateTime')]
        [switch] $ICSDateTime,

        [Parameter(ParameterSetName = 'Format')]
        [string] $Format,

        [Parameter(ParameterSetName = 'DMTF')]
        [Parameter(ParameterSetName = 'Unix')]
        [Parameter(ParameterSetName = 'FileTime')]
        [Parameter(ParameterSetName = 'ICSDateTime')]
        [Parameter(ParameterSetName = 'Format')]
        [Alias('Inc')]
        [switch] $IncludeOriginal,

        [Parameter(ParameterSetName = 'DMTF')]
        [Parameter(ParameterSetName = 'Unix')]
        [Parameter(ParameterSetName = 'FileTime')]
        [Parameter(ParameterSetName = 'ICSDateTime')]
        [Parameter(ParameterSetName = 'Format')]
        [Alias('Zulu')]
        [switch] $UTC
    )
    #endregion parameter

    begin {
        Write-Verbose -Message "Starting [$($MyInvocation.Mycommand)]"
        Write-Verbose -Message "ParameterSetName [$($PsCmdlet.ParameterSetName)]"
        $BeginUnixEpoch = Get-Date -Date '1/1/1970'
        $strCurrentTimeZone = (Get-CimInstance -ClassName win32_timezone).Description
        Write-Verbose -Message "Your local timezone is '$strCurrentTimeZone'"
    }

    process {
        foreach ($D in $DateTime) {
            if ($UTC) {
                $D = ConvertTo-UTC $D
            }

            Write-Verbose -message "You entered a datetime of: '$D'"
            switch ($PsCmdlet.ParameterSetName) {
                'DMTF' {
                    $ReturnVal = [Management.ManagementDateTimeConverter]::ToDmtfDateTime(($D))
                }
                'Unix' {
                    $ReturnVal = ([timespan] ($D - $BeginUnixEpoch)).TotalSeconds
                }
                'FileTime' {
                    $ReturnVal = $D.ToFileTime()
                }
                'ICSDateTime' {
                    if ($UTC) {
                        $ReturnVal = Get-Date -Date $D -Format 'yyyyMMddTHHmmssZ'
                    } else {
                        $ReturnVal = Get-Date -Date $D -Format 'yyyyMMddTHHmmss'
                    }
                }
                'Format' {
                    $ReturnVal = Get-Date -Date $D -Format $Format
                }
            }

            if ($IncludeOriginal) {
                $prop = ([ordered] @{ DateTime = $D } )
                switch ($PsCmdlet.ParameterSetName) {
                    'DMTF' { $prop.DMTF = $ReturnVal }
                    'Unix' { $prop.Unix = $ReturnVal }
                    'FileTime' { $prop.FileTime = $ReturnVal }
                    'ICSDateTime' { $prop.ICSDateTime = $ReturnVal }
                    'Format' { $prop.Format = $ReturnVal }
                }
                New-Object -typename psobject -prop $prop
            } else {
                Write-Output -inputobject $ReturnVal
            }
        }
    }

    end {
        Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
    }

} #EndFunction ConvertFrom-DateTime
