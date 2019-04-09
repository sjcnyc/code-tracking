function ConvertTo-MarkDown {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Generic.List[System.Collections.Hashtable]]
        $InputObject
    )

    process {
        foreach ($Heading in $InputObject) {
            "# {0}" -f $Heading.Heading
            $Heading.Text
            $Subheadings = $Heading.Subheadings
            if ($Heading.Heading -match 'Properties|Methods|Fields') {
                $Subheadings = $Heading.Subheadings | Sort-Object {$_.Heading}
            }
            if ($Heading.Heading -match 'Constructors') {
                $Subheadings = $Heading.Subheadings | Sort-Object -Property @{
                    Expression = {
                        if ($_.Heading -match '\(\)') {-1}
                        else {($_.Heading -split ',').count}
                    }
                    Ascending  = $true
                }
            }
            foreach ($Subheading in $Subheadings) {
                "## {0}" -f $Subheading.Heading
                $Subheading.Text
            }
        }
    }
}

$object2 =
@(
    @{
        Heading     = 'Heading1'
        Text        = 'Heading1 text'
        Subheadings = @(
            @{
                Heading     = 'Subheading1'
                Text        = 'subheading1 text'
                Subheadings = @()
            }
            @{
                Heading     = 'Subheading2'
                Text        = 'subheading2 text'
                Subheadings = @()
            }
        )
    }
    @{
        Heading     = 'Heading2'
        Text        = 'Heading2 text'
        Subheadings = @(
            @{
                Heading     = 'Subheading3'
                Text        = 'subheading3 text'
                Subheadings = @()
            }
            @{
                Heading     = 'Subheading4'
                Text        = 'subheading4 text'
                Subheadings = @()
            }
        )
    }
)

ConvertTo-MarkDown -InputObject $object2
