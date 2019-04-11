$sch = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema()
$de = $sch.GetDirectoryEntry()
switch ($de.ObjectVersion) {
    13{'{0} ' -f "Windows 2000"; break}
    30{"{0} " -f "Windows 2003"; break}
    31{"{0} " -f "Windows 2003 R2"; break}
    44{"{0} " -f "Windows 2008"; break}
    47{"{0} " -f "Windows 2008 R2"; break}
    56{"{0} " -f "Windows 2012"; break}
    69{"{0} " -f "Windows 2012 R2"; break}
    87{"{0} " -f "Windows 2016"; break}
    default{"{0,25} {1,2} " -f "Unknown Schema Version", $($de.ObjectVersion); break}
}