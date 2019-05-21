﻿# PSInteger8ToDate.ps1
# PowerShell script demonstrating how to convert an Integer8 value into
# a datetime value.
#
# ----------------------------------------------------------------------
# Copyright (c) 2011 Richard L. Mueller
# Hilltop Lab web site - http://www.rlmueller.net
# Version 1.0 - March 19, 2011
#
# You have a royalty-free right to use, modify, reproduce, and
# distribute this script file in any way you find useful, provided that
# you agree that the copyright owner above has no warranty, obligations,
# or liability for such use.

# Read Integer8 value from command line or prompt for value.
Param ($Integer)
If ($Integer -eq $Null) {
    $Integer = Read-Host 'Integer8 value'
}

# Convert Integer8 value into datetime in local time zone.
$Date = [DateTime]::FromFileTime($Integer)

# Correct for daylight savings.
If ($Date.IsDaylightSavingTime) {
    $Date = $Date.AddHours(1)
}

# Display the datetime value.
"Local Time: $Date"
'UTC:        ' + $Date.ToUniversalTime()
