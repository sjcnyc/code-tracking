#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : New-WordTable
        Author     : 
        Requires   : PowerShell Version 3.0 
        Date       : 6/22/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

Function New-WordTable {
    [cmdletbinding(
        DefaultParameterSetName='Table'
    )]
    Param (
        [parameter()]
        [object]$WordObject,
        [parameter()]
        [object]$Object,
        [parameter()]
        [int]$Columns,
        [parameter()]
        [int]$Rows,
        [parameter(ParameterSetName='Table')]
        [switch]$AsTable,
        [parameter(ParameterSetName='List')]
        [switch]$AsList,
        [parameter()]
        [string]$TableStyle,
        [parameter()]
        [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]$TableBehavior = 'wdWord9TableBehavior',
        [parameter()]
        [Microsoft.Office.Interop.Word.WdAutoFitBehavior]$AutoFitBehavior = 'wdAutoFitContent'
    )
    #Specifying 0 index ensures we get accurate data from a single object
    $Properties = $Object[0].psobject.properties.name
    $Range = @($WordObject.Paragraphs)[-1].Range
    $Table = $WordObject.Tables.add(
    $WordObject.Range,$Rows,$Columns,$TableBehavior, $AutoFitBehavior)

    Switch ($PSCmdlet.ParameterSetName) {
        'Table' {
            If (-NOT $PSBoundParameters.ContainsKey('TableStyle')) {
                $Table.Style = 'Medium Shading 1 - Accent 1'
            }
            $c = 1
            $r = 1
            #Build header
            $Properties | ForEach {
                Write-Verbose "Adding $($_)"
                $Table.cell($r,$c).range.Bold=1
                $Table.cell($r,$c).range.text = $_
                $c++
            }  
            $c = 1    
            #Add Data
            For ($i=0; $i -lt (($Object | Measure-Object).Count); $i++) {
                $Properties | ForEach {
                    $Table.cell(($i+2),$c).range.Bold=0
                    $Table.cell(($i+2),$c).range.text = $Object[$i].$_
                    $c++
                }
                $c = 1 
            }                 
        }
        'List' {
            If (-NOT $PSBoundParameters.ContainsKey('TableStyle')) {
                $Table.Style = 'Light Shading - Accent 1'
            }
            $c = 1
            $r = 1
            $Properties | ForEach {
                $Table.cell($r,$c).range.Bold=1
                $Table.cell($r,$c).range.text = $_
                $c++
                $Table.cell($r,$c).range.Bold=0
                $Table.cell($r,$c).range.text = $Object.$_
                $c--
                $r++
            }
        }
    }
}


$Word = New-Object -ComObject Word.Application
$Word.Visible = $True
$Document = $Word.Documents.Add()
$Selection = $Word.Selection

$BIOS = @(Get-WmiObject Win32_Bios | ForEach {
    [pscustomobject] @{
        Manufacturer = $_.Manufacturer
        Name = $_.Name
        Version = $_.Version
        SerialNumber = $_.SerialNumber
        BIOSVersion = $_.SMBIOSBIOSVersion
    }
})

New-WordTable -Object $BIOS -Columns 2 -Rows ($BIOS.PSObject.Properties | Measure-Object).Count -AsList