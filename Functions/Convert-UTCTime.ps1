function Convert-UTCTime {
    Param([string]$wmiDateTime)
    $normalDateTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($wmiDateTime)
    $normalDateTime
}

$utcTime = get-wmiobject win32_operatingsystem | select-object –expandproperty LastBootupTime

Convert-UTCTime $utcTime

$utctime