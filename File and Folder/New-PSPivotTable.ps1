#requires -version 2.0

<#
  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
#>

Function New-PSPivotTable {

<#
.Synopsis
Create a Pivot Table
.Description
This command takes the result of a PowerShell expression and creates a
pivot table object. You can use this object to analyze data patterns. For example
you could get a directory listing and then prepare a table showing the size of
different file extensions for each folder.
.Parameter Inputobject
This is the data object to analyze. You must enter as a parameter value. Read
help examples.
.Parameter yLabel
This is an alternative value for the the "Y-Axis". If you don't specify a value
then the yProperty value will be used. Use this parameter when you want to rename
a property value such as Machinename to Computername.
.Parameter yProperty
The property name to pivot on. This is the "Y-Axis" of the pivot table.
.Parameter xLabel
The property name that you want to analyze. The value of each corresponding object
property becomes the label on the "X-Axis". For example, if the inputobject are 
service objects and xLabel is Name, each column will be labeled with the name of a
service object, e.g. Alerter or BITS. See help examples.
.Parameter xProperty
The property name that you want to analyze for each object. See help examples.
.Parameter Count
Instead of getting a property for each xLabel value, return a total count of 
each.
.Parameter Sum
Instead of getting a property for each xLabel value, return a total sum of each.
The parameter value is the object property to measure.
.Parameter Format
If using -Sum the default output is typically bytes, depending on the object.
Use KB, MB, GB or TB to reformat the sum accordingly.
.Parameter Round
Use this value to round a sum, especially if you are formatting it to something
like KB.
.Example
PS C:\> $svc="Lanmanserver","Wuauserv","Bits","Spooler","Audiosrv"
PS C:\> $comps="serenity","quark","jdhit-dc01"
PS C:\> $data=@()
PS C:\> foreach ($computer in $comps) {
>> $data+=$svc | get-service -computername $computer -ea SilentlyContinue 
>> }
>>

PS C:\> new-pspivottable $data -ylabel Computername -yProperty Machinename -xlabel Name -xproperty Status | Format-Table -auto 

Computername Lanmanserver Wuauserv    Bits Spooler Audiosrv
------------ ------------ --------    ---- ------- --------
serenity          Running  Running Running Running  Running
quark                      Stopped Running Running  Running
jdhit-dc01        Running  Running Running Stopped         

Create a table that shows the status of each service on each computer. The yLabel parameter
renames the property so that instead of Machinename it shows Computername. The xLabel is the
property name to analyze, in this case the service name. The xProperty value of each service
becomes the table value.
.Example
PS C:\> $files=dir c:\scripts -include *.ps1,*.txt,*.zip,*.bat -recurse
PS C:\> New-PSPivotTable $files -yProperty Directory -xlabel Extension -count | format-table -auto 

Directory                                        .ZIP .BAT .PS1 .TXT
---------                                        ---- ---- ---- ----
C:\scripts\AD-Old\New                               0    0    1    1
C:\scripts\AD-Old                                   1    0   82    1
C:\scripts\ADTFM-Scripts\LocalUsersGroups           0    0    8    0
C:\scripts\ADTFM-Scripts                            0    0   55    3
C:\scripts\en-US                                    0    0    1    0
C:\scripts\GPAE                                     0    0    8    3
C:\scripts\modhelp                                  1    0    0    0
C:\scripts\PowerShellBingo                          0    0    4    0
C:\scripts\PS-TFM                                   1    0   69    2
C:\scripts\PSVirtualBox                             0    0    0    1
C:\scripts\quark                                    0    0    0    1
C:\scripts\TechEd2012                               1    0   11    3
C:\scripts\Toolmaking\old                           0    0   10    0
C:\scripts\Toolmaking                               0    0   48    0
C:\scripts                                         55   13 1133  305

Display a table report that shows the count of each file type in each directory.
.Example
PS C:\> $files=dir c:\scripts\*.ps*,*.txt,*.zip,*.bat
PS C:\> New-PSPivotTable $files -yProperty Directory -xlabel Extension -Sum Length -round 2 -format kb | format-table -auto 

Directory     .PS1 .PS1XML  .PSM1 .PSD1 .PSSC    .TXT    .ZIP .BAT
---------     ---- -------  ----- ----- -----    ----    ---- ----
C:\scripts 4047.95   15.45 206.56  6.13  4.01 6776.36 1668.52 5.83

Analyse files by extension, measuring the total size of each extension. 
The value is formatted as KB to 2 decimal points.
.Notes
NAME:     New-PSPivotTable
AUTHOR:   Jeffery Hicks (@JeffHicks)
VERSION:  0.9
LASTEDIT: 07/05/2012
BLOG:     http://jdhitsolutions.com/blog

Learn more with a copy of Windows PowerShell 2.0: TFM
or get started on PowerShell v3 with PowerShell in Depth: An Administrator's Guide.
.Link
Measure-Object
Group-Object
Select-Object
#>

[cmdletbinding(DefaultParameterSetName="Property")]

Param(
[Parameter(Position=0,Mandatory=$True)]
[object]$Inputobject,
[Parameter()]
[String]$yLabel,
[Parameter(Mandatory=$True)]
[String]$yProperty,
[Parameter(Mandatory=$True)]
[string]$xLabel,
[Parameter(ParameterSetName="Property")]
[string]$xProperty,
[Parameter(ParameterSetName="Count")]
[switch]$Count,
[Parameter(ParameterSetName="Sum")]
[string]$Sum,
[Parameter(ParameterSetName="Sum")]
[ValidateSet("None","KB","MB","GB","TB")]
[string]$Format="None",
[Parameter(ParameterSetName="Sum")]
[ValidateScript({$_ -gt 0})]
[int]$Round
)

Begin {
    Write-Verbose "Starting $($myinvocation.mycommand)"
    $Activity="PS Pivot Table"
    $status="Creating new table"
    Write-Progress -Activity $Activity -Status $Status
    #initialize an array to hold results
    $result=@()
    #if no yLabel then use yProperty name
    if (-Not $yLabel) {
        $yLabel=$yProperty
    }
    Write-Verbose "Vertical axis label is $ylabel"
}
Process {    
    Write-Progress -Activity $Activity -status "Pre-Processing"
    if ($Count -or $Sum) {
        #create an array of all unique property names so that if one isn't 
        #found we can set a value of 0
        Write-Verbose "Creating a unique list based on $xLabel"
        <#
          Filter out blanks. Uniqueness is case sensitive so we first do a 
          quick filtering with Select-Object, then turn each of them to upper
          case and finally get unique uppercase items. 
        #>
        $unique=$inputobject | Where {$_.$xlabel} | 
         Select-Object -ExpandProperty $xLabel -unique | foreach {
           $_.ToUpper()} | Select-Object -unique
         
        Write-Verbose ($unique -join  ',' | out-String).Trim()
      
    } 
    else {
     Write-Verbose "Processing $xLabel for $xProperty"    
    }
    
    Write-Verbose "Grouping objects on $yProperty"
    Write-Progress -Activity $Activity -status "Pre-Processing" -CurrentOperation "Grouping by $yProperty"
    $grouped=$Inputobject | Group -Property $yProperty
    $status="Analyzing data"  
    $i=0
    $groupcount=($grouped | measure).count
    foreach ($item in $grouped ) {
      Write-Verbose "Item $($item.name)"
      $i++
      #calculate what percentage is complete for Write-Progress
      $percent=($i/$groupcount)*100
      Write-Progress -Activity $Activity -Status $Status -CurrentOperation $($item.Name) -PercentComplete $percent
      $obj=new-object psobject -property @{$yLabel=$item.name}   
      #process each group
        #Calculate value depending on parameter set
        Switch ($pscmdlet.parametersetname) {
        
        "Property" {
                    <#
                      take each property name from the horizontal axis and make 
                      it a property name. Use the grouped property value as the 
                      new value
                    #>
                     $item.group | foreach {
                        $obj | Add-member Noteproperty -name "$($_.$xLabel)" -value $_.$xProperty
                      } #foreach
                    }
        "Count"  {
                    Write-Verbose "Calculating count based on $xLabel"
                     $labelGroup=$item.group | Group-Object -Property $xLabel 
                     #find non-matching labels and set count to 0
                     Write-Verbose "Finding 0 count entries"
                     #make each name upper case
                     $diff=$labelGroup | Select-Object -ExpandProperty Name -unique | 
                     Foreach { $_.ToUpper()} |Select-Object -unique
                     
                     #compare the master list of unique labels with what is in this group
                     Compare-Object -ReferenceObject $Unique -DifferenceObject $diff | 
                     Select-Object -ExpandProperty inputobject | foreach {
                        #add each item and set the value to 0
                        Write-Verbose "Setting $_ to 0"
                        $obj | Add-member Noteproperty -name $_ -value 0
                     }
                     
                     Write-Verbose "Counting entries"
                     $labelGroup | foreach {
                        $n=($_.name).ToUpper()
                        write-verbose $n
                        $obj | Add-member Noteproperty -name $n -value $_.Count -force
                    } #foreach
                 }
         "Sum"  {
                    Write-Verbose "Calculating sum based on $xLabel using $sum"
                    $labelGroup=$item.group | Group-Object -Property $xLabel 
                 
                     #find non-matching labels and set count to 0
                     Write-Verbose "Finding 0 count entries"
                     #make each name upper case
                     $diff=$labelGroup | Select-Object -ExpandProperty Name -unique | 
                     Foreach { $_.ToUpper()} |Select-Object -unique
                     
                     #compare the master list of unique labels with what is in this group
                     Compare-Object -ReferenceObject $Unique -DifferenceObject $diff | 
                     Select-Object -ExpandProperty inputobject | foreach {
                        #add each item and set the value to 0
                        Write-Verbose "Setting $_ sum to 0"
                        $obj | Add-member Noteproperty -name $_ -value 0
                     }
                     
                     Write-Verbose "Measuring entries"
                     $labelGroup | foreach {
                        $n=($_.name).ToUpper()
                        write-verbose "Measuring $n"
                        
                        $measure= $_.Group | Measure-Object -Property $Sum -sum
                        if ($Format -eq "None") {
                            $value=$measure.sum
                        }
                        else {
                            Write-Verbose "Formatting to $Format"
                             $value=$measure.sum/"1$Format"
                            }
                        if ($Round) {
                            Write-Verbose "Rounding to $Round places"
                            $Value=[math]::Round($value,$round)
                        }
                        $obj | Add-member Noteproperty -name $n -value $value -force
                    } #foreach
                   
                }        
        } #switch

        #add each object to the results array
      $result+=$obj
    } #foreach item
} #process
End {
    Write-Verbose "Writing results to the pipeline"
    $result
    Write-Verbose "Ending $($myinvocation.mycommand)"
    Write-Progress -Completed -Activity $Activity -Status "Ending"
}
} #end function
