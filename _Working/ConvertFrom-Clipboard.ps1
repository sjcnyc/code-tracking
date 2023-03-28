function ConvertFrom-Clipboard {
    <#
    .SYNOPSIS
        Converts from a string array into a comma separated string surrounded with quotes.
    .DESCRIPTION
        Converts from a string array into a comma separated string surrounded with quotes.
        This function was originally created to easily copy / paste server names from a spreadsheet or list and then be able to copy them into a single string that can easily be pasted for automation tasks.
    .PARAMETER InputObject
        Specifies an array of strings received from the pipeline, or a variable that contains a string array object.
    .EXAMPLE
        Get-Clipboard | ConvertFrom-Clipboard
        Clipboard is:
        SERVER1
        SERVER2
        SERVER4
        Results in:
        "SERVER1","SERVER2","SERVER4"
    .EXAMPLE
        ConvertFrom-Clipboard (Get-Clipboard)

        Clipboard is:
        SERVER1
        SERVER2
        SERVER4
        Results in:
        "SERVER1","SERVER2","SERVER4"
    .EXAMPLE
        Get-Clipboard | ConvertFrom-Clipboard | Set-Clipboard
        Clipboard is:
        SERVER1
        SERVER2
        SERVER4
        Overwrites clipboard with:
        "SERVER1","SERVER2","SERVER4"
    #>
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()][AllowEmptyString()]
        [String[]]$InputObject
    )
    begin {
        [String]$Results = ""

    }
    process {
        if ($InputObject.GetType().IsArray) {
            foreach ($item in $InputObject) {
                if (-not [String]::IsNullOrEmpty($item)) {
                    if (-not $item.Contains('"')) {
                        $Results += """$($item)"","
                    } else {
                        $Results += "$($item),"
                    }
                }
            }
        }
    }
    end {
        if (-not [String]::IsNullOrEmpty($Results)) {
            if ($Results.EndsWith(",")) {
                $Results.Substring(0, $Results.Length - 1)
            } else {
                $Results
            }
        }
    }
}