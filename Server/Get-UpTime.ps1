$utcTime = get-wmiobject win32_operatingsystem | select-object –expandproperty LastBootupTime

Function Convert-WMIDateTime{
 Param([string]$wmiDateTime)
 $normalDateTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($wmiDateTime)
 $normalDateTime
 }

Convert-WMIDateTime $utcTime