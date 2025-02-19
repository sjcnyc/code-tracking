function Join-Tables {
    <#
    .SYNOPSIS
        Function to join tables based on one or more common columns with an option to summarize (aggregate) joined columns.
        
    .DESCRIPTION
		Merge two separate tables (left outer join) into one joined table based on one or more common columns similar to a vlookup in MS Excel.
		In addition the values of specified number based columns can be optionally summarized using 
		an aggregate function (sum,max,min,count,average) similar to the functionality of a pivot table.
		
    .PARAMETER lookupColumns
        One or multiple column(s) the tables are joined on.
    
    .PARAMETER refTable
        The reference table for the join operation. All records from this table will be part of the joined table
		
	.PARAMETER lookupTable
		The lookup table for the join operation. Only matching records will be part of the joined table
	
	.PARAMETER aggregates
		A hashtable where the keys represent number based columnnames and the values represent one of the following 
		aggregate functions (sum,maximum,minimum,average,count)
#>
    [cmdletbinding()]
    param(
        $lookupColumns,
        $refTable,
        $lookupTable,
        $aggregates
    )
    $sbLookupValues = [scriptblock]::Create($(($lookupColumns | ForEach-Object {'$_."' + $_ + '"'}) -join "+"))
    $dict = $lookupTable | Group-Object $sbLookupValues -AsHashTable -AsString
    $additionalProps = Compare-Object ($refTable | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) ($lookupTable | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name) |
        Where-Object {$_.SideIndicator -eq "=>"} | Select-Object -ExpandProperty InputObject
    $intersection = Compare-Object $refTable $lookupTable -Property $lookupColumns -IncludeEqual -ExcludeDifferent -PassThru
    foreach ($prop in $additionalProps) { $refTable | Add-Member -MemberType NoteProperty -Name $prop -Value $null -Force}
    foreach ($item in ($refTable | Where-Object {$_.SideIndicator -EQ "=="})) {
        $lookupKey = $(foreach ($key in $lookupColumns) { $item.$key} ) -join ""
        #|select * part only necessary for v2
        $newVals = $dict."$lookupKey" | Select-Object *
        foreach ( $prop in $additionalProps) {
            $item."$prop" = $newVals."$prop"
        }
        if ($aggregates) {
            foreach ($group in $aggregates.GetEnumerator()) {
                $item."$($group.key)" = (@($newVals."$($group.key)") + @($item."$($group.key)") |
                        Measure-Object -Sum -Maximum -Minimum -Average)."$($group.value)"
            }
        }
    }
    $refTable | Select-Object * -ExcludeProperty SideIndicator
}

$FirstCollection = @"
  FirstName,  LastName,   MailingAddress,    EmployeeID
  John,       Doe,        123 First Ave,     J8329029
  Susan Q.,   Public,     3025 South Street, K4367143
  Dirk,       Doe,        123 First Ave,     J8329030
  Carol,   Public,     3025 South Street, K4367144
  John,       Doe,        123 First Ave,     J8329031
  Susan Q.,   Public,     3025 South Street, K4367145
  Peter,   Public,     3025 South Street, K4367146
"@.Split("`n") | ForEach-Object {$_.trim()} | ConvertFrom-Csv

$SecondCollection = @"
  ID,    Week, HrsWorked,   PayRate,  EmployeeID
  12276, 12,   40,          55,       J8329029
  12277, 13,   40,          55,       J8329030
  12278, 14,   42,          55,       J8329031
  12279, 12,   35,          40,       K4367143
  12280, 13,   32,          40,       K4367144
  12281, 14,   48,          40,       K4367145
"@.Split("`n") | ForEach-Object {$_.trim()} | ConvertFrom-Csv

#Join tables on EmployeeID column
Join-Tables employeeid $FirstCollection $SecondCollection | ft -AutoSize


$table1 =
@"
firstname,lastname,city,country,sales
john,doe,NYC,USA,11
john,wayne,Hamburg,Germany,88
peter,new,Washington,USA,44
gary,henderson,LA,USA,55
"@ | ConvertFrom-Csv

$table2 = 
@"
firstname,lastname,city,zip,age,sales
john,doe,NYC,2222,12,55
nate,robbins,LA,3333,23,66
john,wayne,Hamburg,8888,36,124
peter,new,Washington,6666,45,99
"@ | ConvertFrom-Csv
#Join two tables based on two lookup columns summing up the sales column
Join-Tables ("firstname", "lastname") $table1 $table2 @{sales = "sum"} | Format-Table