function Compare-CsvFile {
        <#
        .SYNOPSIS
            This function compares two CSV files and all columns inside the CSV files based off
            of a unique row identifier.  If any field is different in the row it will output
            the fields and values as object properties
        .PARAMETER ReferenceCsv
            The CSV file to base matches against.
        .PARAMETER DifferenceCsv
            The CSV file to match ReferenceCsv against.
        .PARAMETER UniqueIdentifier
            This is the name of the field in both CSVs that contains unique values.  This is used to compare the rows
            in each CSV.
        .EXAMPLE
            PS> Compare-CsvFile -ReferenceCsv 'C:\csv1.csv' -DifferenceCsv 'C:\csv2.csv' -UniqueIdentifier OrderNumber
    
            This example assumes each CSV file referenced has a field called OrderNumber and each order number in that field
            is unique inside each of the CSV files.  The function will read all order numbers in the ReferenceCsv and attempt
            to find a match in the OrderNumber field in DifferenceCsv.  Once a match is found, it will then read all fields and values
            in those rows and if any value does not match the other it will be output.
        #>
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [string]$UniqueIdentifier,

            [Parameter(Mandatory)]
            [ValidateScript({
                if (!(Test-Path -Path $_ -PathType Leaf))
                {
                    throw "The reference CSV file $($_) cannot be found"
                }
                else
                {
                    $true
                }
            })]
            [string]$ReferenceCsv,

            [Parameter(Mandatory)]
            [ValidateScript({
                if (!(Test-Path -Path $_ -PathType Leaf))
                {
                    throw "The difference CSV file $($_) cannot be found"
                }
                else
                {
                    $true
                }
            })]
            [string]$DifferenceCsv
        )
        process
        {
            try
            {
                ## Import both CSV to begin comparisons
                $RefCsvData = Import-Csv -Path $ReferenceCsv
                $DiffCsvData = Import-Csv -Path $DifferenceCsv
                ## Begin checking each row in the reference CSV
                foreach ($RefCsvRow in $RefCsvData)
                {
                    ## Find the row match in the difference CSV from the unique ID specified
                    $DiffCsvRow = $DiffCsvData | Where-Object {$_.$UniqueIdentifier -eq $RefCsvRow.$UniqueIdentifier}
                    ## If any matches were found
                    if ($DiffCsvRow)
                    {
                        ## There should be only be a single match.  If the UniqueIdentifier param is actually unique
                        ## there should always be only one match
                        if ($DiffCsvRow -is [array])
                        {
                            throw "Multiple matches found in difference CSV for unique ID $UniqueIdentifier"
                        }
                        else
                        {
                            ## Beging checking each column (property) in the reference CSV excluding the unique ID property
                            foreach ($RefCsvProp in ($RefCsvRow.PsObject.Properties | Where-Object {$_.Name -ne $UniqueIdentifier}))
                            {
                                ## Begin comparing the difference CSV columns (properties) for each row
                                foreach ($DiffCsvProp in $DiffCsvRow.PSObject.Properties)
                                {
                                    ## If the field names match we can then compare the values
                                    if ($RefCsvProp.Name -eq $DiffCsvProp.Name)
                                    {
                                        ## Create the output object
                                        $CompareObject = @{
                                            $UniqueIdentifier = $RefCsvRow.$UniqueIdentifier
                                            'Field' = $RefCsvProp.Name
                                            'ReferenceCsvValue' = $RefCsvProp.Value
                                            'DifferenceCsvValue' = $DiffCsvProp.Value
                                        }
                                        if ($RefCsvProp.Value -ne $DiffCsvProp.Value)
                                        {
                                            $CompareObject.Result = '<>'
                                        }
                                        else
                                        {
                                            $CompareObject.Result = '=='
                                        }
                                        [pscustomobject]$CompareObject
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "No matches found for $UniqueIdentifier in difference CSV"
                    }
                }
            }
            catch
            {
                Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                $false
            }
        }
    }