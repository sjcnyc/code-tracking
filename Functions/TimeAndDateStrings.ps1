﻿Get-qaduser  sconnea | Select-Object samaccountname, WhenCreated,
@{Name = 'ShortDate'; Expression = { '{0:d}' -f $_.WhenCreated} },
@{N = 'LongDate'; E = { '{0:D}' -f $_.WhenCreated} },
@{L = 'FullDateShortTime'; E = { '{0:f}' -f $_.WhenCreated} },
@{N = 'FullDateLongTime'; E = { '{0:F}' -f $_.WhenCreated} },
@{N = 'GeneralDateShortTime'; E = { '{0:g}' -f $_.WhenCreated} },
@{N = 'GeneralDateLongTime'; E = { '{0:G}' -f $_.WhenCreated} },
@{N = 'Month'; E = { '{0:M MM MMM MMMM}' -f $_.WhenCreated} },
@{N = 'Day'; E = { '{0:d dd ddd dddd}' -f $_.WhenCreated} },
@{N = 'Year'; E = { '{0:y yy yyy yyyy}' -f $_.WhenCreated} },
@{N = 'Hour'; E = { '{0:h hh H HH}' -f $_.WhenCreated} },
@{N = 'Minute'; E = { '{0:m mm}' -f $_.WhenCreated} },
@{N = 'Second'; E = { '{0:s ss}' -f $_.WhenCreated} },
@{N = 'AM/PM'; E = { '{0:t tt}' -f $_.WhenCreated} },
@{N = 'CustomDateTime1'; E = { '{0:M-d-YY_h-m-tt}' -f $_.WhenCreated} },
@{N = 'CustomDateTime2'; E = { '{:ss}' -f $_.WhenCreated} }