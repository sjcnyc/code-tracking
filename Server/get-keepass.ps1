Function Get-Kpass {
    param (
        [Parameter(Mandatory)][string]$Entry
    )
    try {
        Initialize-KeePass -PathToKeePassFolder "${env:ProgramFiles(x86)}\KeePass Password Safe 2"
        $response = Read-Host -Prompt 'Enter Password' -AsSecureString
        $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response))
        $kdbx = Get-KPDatabase -path '\\storage\wwinfra$\Documentation\KeePass\SME_KeePassDatabase.kdbx' -MasterPassword $password
        $info = Get-KPAccount -kpDatabase $kdbx -Title ('{0}*' -f ($Entry))

        $result = New-Object -TypeName System.Collections.ArrayList

        foreach ($i in $info) {
            $passkb = keepass_utils\Get-KPPassword -Account $i

            $passinfo = [pscustomobject] @{
                Title = $i.Title
                UserName = $i.username
                Password = $passkb
            }
            $null = $result.Add($passinfo)
        }
        $result
    }
    catch {
        $line = $_.InvocationInfo.ScriptLineNumber
        ('Error was in Line {0}, {1}' -f ($line), $_)
    }
}