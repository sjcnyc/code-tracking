# Source https://gallery.technet.microsoft.com/Remove-Invalid-Characters-39fa17b1

<#PSScriptInfo
.VERSION 1.5.1
.GUID fb77c199-25b8-4a26-ad12-300aa633d9ee
.AUTHOR Chris Carter
.COMPANYNAME
.COPYRIGHT 2016 Chris Carter
.TAGS RegularExpression StringFormatting InvalidFileNameCharacters
.LICENSEURI http://creativecommons.org/licenses/by-sa/4.0/
.PROJECTURI https://gallery.technet.microsoft.com/Remove-Invalid-Characters-39fa17b1
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
The parameter RemoveOnly has been added. This will exempt certain characters from being replaced with the Replacement string, and they will simply be removed.
#>

function Remove-InvalidFileNameChar
{
<#
.SYNOPSIS
    Removes characters from a string that are not valid in Windows file names.
.DESCRIPTION
    Remove-InvalidFileNameChar accepts a string and removes characters that are invalid in Windows file names.  It then outputs the cleaned string.  By default the space character is ignored, but can be included using the RemoveSpace parameter.

    The Replacement parameter will replace the invalid characters with the specified string. Its companion RemoveOnly will exempt given invalid characters from being replaced, and will simply be removed. Charcters in this list can be given as a string or their decimal or hexadecimal representation.

    The Name parameter can also clean file paths. If the string begins with "\\" or a drive like "C:\", it will then treat the string as a file path and clean the strings between "\".  This has the side effect of removing the ability to actually remove the "\" character from strings since it will then be considered a divider.
.PARAMETER Name
    Specifies the file name to strip of invalid characters.
.PARAMETER Replacement
    Specifies the string to use as a replacement for the invalid characters.
.PARAMETER RemoveOnly
    Specifes the list of invalid characters to remove from the string instead of being replaced by the Replacement parameter value. This may be given as one character strings, or their decimal or hexidecimal values.
.PARAMETER RemoveSpace
    The RemoveSpace parameter will include the space character (U+0020) in the removal process.
.INPUTS
    System.String
    Remove-InvalidFileNameChar accepts System.String objects in the pipeline.

    Remove-InvalidFileNameChar accepts System.String objects in a property Name from objects in the pipeline.
.OUTPUTS
    System.String
.EXAMPLE
    PS C:\> Remove-InvalidFileNameChar -Name "<This /name \is* an :illegal ?filename>.txt"
    Will return
    This name is an illegal filename.txt
.EXAMPLE
    PS C:\> Remove-InvalidFileNameChar -Name "<This /name \is* an :illegal ?filename>.txt" -RemoveSpace
    Will return
    Thisnameisanillegalfilename.txt
.EXAMPLE
    PS C:\> Remove-InvalidFileNameChar -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"'
    Will return
    \\Path\With\Illegal Characters.txt

    This command will strip the invalid characters from the path and output a valid path. Note: it would not be able to remove the "\" character.
.EXAMPLE
    PS C:\> Remove-InvalidFileNameChar -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"' -RemoveSpace
    Output: \\Path\With\IllegalCharacters.txt

    This command will strip the invalid characters from the path and output a valid path, also removing the space character (U+0020) as well. Note: it would not be able to remove the "\" character.
.EXAMPLE
    PS C:\> Remove-InvalidFileNameChar -Name "<This /name \is* an :illegal ?filename>.txt" -Replacement +
    Output: +This +name +is+ an +illegal +filename+.txt

    This command will strip the invalid characters from the string, replacing them with a "+", and outputting the result string.
.EXAMPLE
    PS  C:\> Remove-InvalidFileNameChar -Name "<This /name \is* an :illegal ?filename>.txt" -Replacemet + -RemoveOnly "*", 58, 0x3f
    Output: +This +name +is an illegal filename+.txt

    This command will strip the invalid characters from the string, replacing them with a "+", except the "*", the charcter with a decimal value of 58 (:), and the character with a hexidecimal value of 0x3f (?). These will simply be removed, and the resulting string output.
.NOTES
    Author:  Chris Carter
    Version: 1.5.1
    Last Updated: August 8, 2016
.LINK
    System.RegEx
.LINK
    about_Join
.LINK
    about_Operators
#>

    #region Parameters
    #Requires -Version 2.0
    [CmdletBinding(
            DefaultParameterSetName='Normal',
            HelpURI='https://gallery.technet.microsoft.com/scriptcenter/Remove-Invalid-Characters-39fa17b1'
    )]

    Param(
        [Parameter(Mandatory,HelpMessage='Add help message for user',Position=0,ValueFromPipeline,
                   ValueFromPipelineByPropertyName,ParameterSetName='Normal')]
        [Parameter(Mandatory,Position=0,ValueFromPipeline,
                   ValueFromPipelineByPropertyName,ParameterSetName='Replace')]
            [String[]] $Name,

        [Parameter(Mandatory,HelpMessage='Add help message for user',Position=1,ParameterSetName='Replace')]
            [String] $Replacement,

        [Parameter(Position=2,ParameterSetName='Replace')]
            [Alias('RO')]
            [Object[]] $RemoveOnly,

        [Parameter(ParameterSetName='Normal')]
        [Parameter(ParameterSetName='Replace')]
        [Alias('RS')]
        [switch] $RemoveSpace
    )
    #endregion Parameters

    Begin
    {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
        #Get an array of invalid characters
        $arrInvalidChars = [System.IO.Path]::GetInvalidFileNameChars()

        #Cast into a string. This will include the space character
        $invalidCharsWithSpace = [RegEx]::Escape([String] $arrInvalidChars)

        #Join into a string. This will not include the space character
        $invalidCharsNoSpace = [RegEx]::Escape(-join $arrInvalidChars)

        #Check that the Replacement does not have invalid characters itself
        if ($RemoveSpace)
        {
            if ($Replacement -match "[$invalidCharsWithSpace]")
            {
                Write-Error -Message 'The replacement string also contains invalid filename characters.'
                return
            }
        }
        else
        {
            if ($Replacement -match "[$invalidCharsNoSpace]")
            {
                Write-Error -Message 'The replacement string also contains invalid filename characters.'
                return
            }
        }

        Function Remove-Char
        {
            <#
                    .SYNOPSIS
                    Describe purpose of "Remove-Char" in 1-2 sentences.

                    .DESCRIPTION
                    Add a more complete description of what the function does.

                    .PARAMETER String
                    Describe parameter -String.

                    .EXAMPLE
                    Remove-Char -String Value
                    Describe what this call does

                    .NOTES
                    Place additional notes here.

                    .LINK
                    URLs to related sites
                    The first link is opened by Get-Help -Online Remove-Char

                    .INPUTS
                    List of input types that are accepted by this function.

                    .OUTPUTS
                    List of output types produced by this function.
            #>


            #Test if any charcters should just be removed first instead of replaced.

            [CmdletBinding()]
            param
            (
                $String
            )
            if ($RemoveOnly)
            {
                $String = Remove-ExemptCharFromReplacement -String $String
            }
            #Replace the invalid characters with a blank string(removal) or the replacement value
            #Perform replacement based on whether spaces are desired or not
            if ($RemoveSpace)
            {
                [RegEx]::Replace($String, "[$invalidCharsWithSpace]", $Replacement)
            }
            else
            {
                [RegEx]::Replace($String, "[$invalidCharsNoSpace]", $Replacement)
            }
        }

        Function Remove-ExemptCharFromReplacement
        {
            <#
                    .SYNOPSIS
                    Describe purpose of "Remove-ExemptCharFromReplacement" in 1-2 sentences.

                    .DESCRIPTION
                    Add a more complete description of what the function does.

                    .PARAMETER String
                    Describe parameter -String.

                    .EXAMPLE
                    Remove-ExemptCharFromReplacement -String Value
                    Describe what this call does

                    .NOTES
                    Place additional notes here.

                    .LINK
                    URLs to related sites
                    The first link is opened by Get-Help -Online Remove-ExemptCharFromReplacement

                    .INPUTS
                    List of input types that are accepted by this function.

                    .OUTPUTS
                    List of output types produced by this function.
            #>


            #Remove the characters in RemoveOnly first before returning to the potential replacement
            #Test that the entries are invalid filename characters, and are able to be converted to chars

            [CmdletBinding()]
            param
            (
                $String
            )
            $RemoveOnly = [RegEx]::Escape(-join $(foreach ($entry in $RemoveOnly)
                    {
                        #Try to cast to an int in case a valid integer as a string is passed.
                        try
                        {
                            $entry = [int] $entry
                        }
                        catch
                        {
                            #Silently ignore if it fails.
                            write-error 'blah'
                        }
                        try
                        {
                            $char = [char] $entry
                        }
                        catch
                        {
                            Write-Error -Message "The entry `"$entry`" in RemoveOnly cannot be converted to a type of System.Char. Make sure the entry is either an integer or a one character string."
                            return
                        }

                        if ($arrInvalidChars -contains $char -or $char -eq [char]32)
                        {
                            #Honor the RemoveSpace parameter
                            if (!$RemoveSpace -and $char -eq [char]32)
                            {
                                Write-Warning -Message "The entry `"$char`" in RemoveOnly is a valid filename character, and does not need to be removed. This entry will be ignored."
                            }
                            else
                            {
                                $char
                            }
                        }
                        else
                        {
                            Write-Warning -Message "The entry `"$char`" in RemoveOnly is a valid filename character, and does not need to be removed. This entry will be ignored."
                        }
            }))

            #Remove the exempt characters first before sending back
            [RegEx]::Replace($String, "[$RemoveOnly]", '')
        }
    } #EndBegin

    Process
    {
        foreach ($n in $Name) {
            #Check if the string matches a valid path
            if ($n -match '(?<start>^[a-zA-z]:\\|^\\\\)(?<path>(?:[^\\]+\\)+)(?<file>[^\\]+)$')
            {
                #Split the path into separate directories
                $path = $Matches.path -split '\\'
                #This will remove any empty elements after the split, eg. double slashes "\\"
                $path = $path | Where-Object {$_}
                #Add the filename to the array
                $path += $Matches.file
                #Send each part of the path, except the start, to the removal function
                $cleanPaths = foreach ($p in $path) {
                                  Remove-Char -String $p
                              }
                #Remove any blank elements left after removal.
                $cleanPaths = $cleanPaths | Where-Object {$_}

                #Combine the path together again
                $Matches.start + ($cleanPaths -join '\')
            }
            else
            {
                #String is not a path, so send immediately to the removal function
                Remove-Char -String $n
            }
        }
    } #EndProcess

    End {
        Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
    }

} #EndFunction Remove-InvalidFileNameChar
