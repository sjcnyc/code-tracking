function Format-Phone {

    <#
    .SYNOPSIS
        This function is designed to format a mixed string of 1-16 digit numbers as a phone number.
    
    .DESCRIPTION
        This function will take a string of numbers and letters or special characters and output a formatted
        phone number object.  All non-interger characters are stripped out and replaced in the proper place.
        This module was created with US phone numbers in mind.  If you want to format for another country or
        spec, please create an issue on GitHub.
        
    .PARAMETER InputNumber
        This is the only parameter.  It is the number or string to be formatted
    
    .EXAMPLE
         format-phone -InputNumber +12349215237
    
    .EXAMPLE
         (format-phone -InputNumber 1-2349215237).PrettyNumber
    
    .EXAMPLE
         (format-phone -InputNumber 6432215237).AreaCode
    
    .INPUTS
        String
    
    .OUTPUTS
        PSCustomObject
    
    .NOTES
        Author:  Zachary Bonjour
        Website: https://www.linkedin.com/in/zachary-bonjour/
    #>
    
       [CmdletBinding()]
       param (
          [Parameter(Mandatory)]
          [string]$InputNumber
          )

    $OutputNumber = $InputNumber -replace "[^0-9]"
    $PhoneArray   = $OutputNumber.ToCharArray()
    $PhoneCountry = $PhoneArray[-17..-11] -join("")
    $PhoneArea    = $PhoneArray[-10..-8] -join("")
    $PhonePrefix  = $PhoneArray[-7..-5] -join("")
    $PhoneLine    = $PhoneArray[-4..-1] -join("")

    Switch ($OutputNumber) {
        # 1-4 digits
        {($_.length) -gt 0 -and ($_.length) -lt 5}  {$OutputNumber = $PhoneLine}

        # 5-7 digits
        {($_.length) -gt 4 -and ($_.length) -lt 8} {$OutputNumber = $PhonePrefix + "-" + $PhoneLine}

        # 8-10 digits
        {($_.length) -gt 7 -and ($_.length) -lt 11} {$OutputNumber = "(" + $PhoneArea + ")" + " " + $PhonePrefix + "-" + $PhoneLine}

        # more than 10 digits
        {($_.length) -gt 10} {$OutputNumber = "+" + $PhoneCountry + "(" + $PhoneArea + ")" + " " + $PhonePrefix + "-" + $PhoneLine}
    }

    $OutputObject = [PSCustomObject]@{
        CountryCode  = $PhoneCountry
        AreaCode     = $PhoneArea
        CityPrefix   = $PhonePrefix
        PhoneLine    = $PhoneLine
        PrettyNumber = $OutputNumber
        PrettyNoIntl = $OutputNumber.Replace(("+" + $PhoneCountry),"")
        PlainNumber  = $OutputNumber -replace "[^0-9]"
    }
    $OutputObject
}