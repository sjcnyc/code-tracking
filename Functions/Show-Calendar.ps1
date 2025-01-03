Function Show-Calendar {
<#
.SYNOPSIS
    Displays a visual representation of a calendar.

.DESCRIPTION
    Displays a visual representation of a calendar. This function supports multiple months and lets you highlight specific date ranges or days.

.PARAMETER Start
    The first month to display.

.PARAMETER End
    The last month to display.

.PARAMETER FirstDayOfWeek
    The day of the month on which the week begins.

.PARAMETER HighlightDay
    Specific days (numbered) to highlight. Used for date ranges like (25..31).
    Date ranges are specified by the Windows PowerShell range syntax. These dates are
    enclosed in square brackets.

.PARAMETER HighlightDate
    Specific days (named) to highlight. These dates are surrounded by asterisks.

.EXAMPLE
    # Show a default display of this month.
    Show-Calendar

.EXAMPLE
    # Display a date range.
    Show-Calendar -Start "March, 2010" -End "May, 2010"

.EXAMPLE
    # Highlight a range of days.
    Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"
#>

    [CmdletBinding(ConfirmImpact='None')]
    [OutputType('string')]
    param(
        [DateTime] $start = [DateTime]::Today,
        [DateTime] $end = $start,
        [string] $firstDayOfWeek,
        [int[]] $highlightDay,
        [string[]] $highlightDate = [DateTime]::Today.ToString()
        )

    ## Determine the first day of the start and end months.
    $start = New-Object -TypeName DateTime -ArgumentList $start.Year,$start.Month,1
    $end = New-Object -TypeName DateTime -ArgumentList $end.Year,$end.Month,1
    ## Convert the highlighted dates into real dates.
    [DateTime[]] $highlightDate = [DateTime[]] $highlightDate
    ## Retrieve the DateTimeFormat information so that the
    ## calendar can be manipulated.
    $dateTimeFormat  = (Get-Culture).DateTimeFormat
    if($firstDayOfWeek) {
        $dateTimeFormat.FirstDayOfWeek = $firstDayOfWeek
    }
    $currentDay = $start
    ## Process the requested months.
    while ($start -le $end) {
        ## Return to an earlier point in the function if the first day of the month
        ## is in the middle of the week.
        while($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek) {
            $currentDay = $currentDay.AddDays(-1)
        }
        ## Prepare to store information about this date range.
        $currentWeek = New-Object -TypeName PsObject
        $dayNames = @()
        $weeks = @()
        ## Continue processing dates until the function reaches the end of the month.
        ## The function continues until the week is completed with
        ## days from the next month.
        while (($currentDay -lt $start.AddMonths(1)) -or
            ($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek))
        {
            ## Determine the day names to use to label the columns.
            $dayName = '{0:ddd}' -f $currentDay
            if ($dayNames -notcontains $dayName) {
                $dayNames += $dayName
            }
            ## Pad the day number for display, highlighting if necessary.
            $displayDay = ' {0,2} ' -f $currentDay.Day
            ## Determine whether to highlight a specific date.
            if ($highlightDate) {
                $compareDate = New-Object -TypeName DateTime -ArgumentList $currentDay.Year,
                    $currentDay.Month,$currentDay.Day
                if($highlightDate -contains $compareDate) {
                    $displayDay = '*' + ('{0,2}' -f $currentDay.Day) + '*'
                }
            }
            ## Otherwise, highlight as part of a date range.
            if ($highlightDay -and ($highlightDay[0] -eq $currentDay.Day)) {
                $displayDay = '[' + ('{0,2}' -f $currentDay.Day) + ']'
                $null,$highlightDay = $highlightDay
            }
            ## Add the day of the week and the day of the month as note properties.
            $currentWeek | Add-Member -NotePropertyName NoteProperty -NotePropertyValue $dayName -InputObject $displayDay
            ## Move to the next day of the month.
            $currentDay = $currentDay.AddDays(1)
            ## If the function reaches the next week, store the current week
            ## in the week list and continue.
            if ($currentDay.DayOfWeek -eq $dateTimeFormat.FirstDayOfWeek) {
                $weeks += $currentWeek
                $currentWeek = New-Object -TypeName PsObject
            }
        }
        ## Format the weeks as a table.
        $calendar = $weeks | Format-Table -Property $dayNames -AutoSize | Out-String
        ## Add a centered header.
        $width = ($calendar.Split("`n") | Measure-Object -Maximum -Property Length).Maximum
        $header = '{0:MMMM yyyy}' -f $start
        $padding = ' ' * (($width - $header.Length) / 2)
        $displayCalendar = " `n" + $padding + $header + "`n " + $calendar
        $displayCalendar.TrimEnd()
        ## Move to the next month.
        $start = $start.AddMonths(1)
    }
} #EndFunction Show-Calendar
