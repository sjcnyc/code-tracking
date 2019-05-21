Function Convert-Size {
    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias("Length")]
        [int64]$Size
    )
    Begin {
        If (-Not $ConvertSize) {
            Write-Verbose ("Creating signature from Win32API")
            $Signature =
            @"
                [DllImport("Shlwapi.dll", CharSet = CharSet.Auto)]
                public static extern long StrFormatByteSize( long fileSize, System.Text.StringBuilder buffer, int bufferSize );
"@
            $Global:ConvertSize = Add-Type -Name SizeConverter -MemberDefinition $Signature -PassThru
        }
        Write-Verbose ("Building buffer for string")
        $stringBuilder = New-Object Text.StringBuilder 1024
    }
    Process {
        Write-Verbose ("Converting {0} to upper most size" -f $Size)
        $ConvertSize::StrFormatByteSize( $Size, $stringBuilder, $stringBuilder.Capacity ) | Out-Null
        $stringBuilder.ToString()
    }
}