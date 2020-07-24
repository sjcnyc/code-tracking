Function TranslateFlags {
  Param (
    [Parameter(mandatory = $true, valuefrompipeline = $true)]
    $UserName
  )
    
  # Define the flags
  $flags = @{
    SCRIPT                                 = 1        # 0x1
    ACCOUNTDISABLE                         = 2        # 0x2
    HOMEDIR_REQUIRED                       = 8        # 0x8
    LOCKOUT                                = 16       # 0x10
    PASSWD_NOTREQD                         = 32       # 0x20
    PASSWD_CANT_CHANGE                     = 64       # 0x40
    ENCRYPTED_TEXT_PASSWORD_ALLOWED        = 128      # 0x80
    TEMP_DUPLICATE_ACCOUNT                 = 256      # 0x100
    NORMAL_ACCOUNT                         = 512      # 0x200
    INTERDOMAIN_TRUST_ACCOUNT              = 2048     # 0x800
    WORKSTATION_TRUST_ACCOUNT              = 4096     # 0x1000
    SERVER_TRUST_ACCOUNT                   = 8192     # 0x2000
    DONT_EXPIRE_PASSWD                     = 65536    # 0x10000
    MNS_LOGON_ACCOUNT                      = 131072   # 0x20000
    SMARTCARD_REQUIRED                     = 262144   # 0x40000
    TRUSTED_FOR_DELEGATION                 = 524288   # 0x80000
    NOT_DELEGATED                          = 1048576  # 0x100000
    USE_DES_KEY_ONLY                       = 2097152  # 0x200000
    DONT_REQUIRE_PREAUTH                   = 4194304  # 0x400000
    PASSWORD_EXPIRED                       = 8388608  # 0x800000
    TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION = 16777216 # 0x1000000
  }
    
  # Get pipeline input if applicable
  $pipeline = @($input)
  if ($pipeline.count -gt 0) {
    $UserList = $pipeline
  }
  else {
    $UserList = @($UserName)
  }

  # Build our directory searcher
  $ds = New-Object system.directoryservices.directorysearcher
  $ds.PageSize = 1000
  $ds.Filter = "(|"
  ForEach ($User in $UserList) {
    $ds.Filter += "(name={0})" -f $User
  }
  $ds.filter += ")"
  [void]$ds.PropertiesToLoad.Add("Name")
  [void]$ds.PropertiesToLoad.Add("useraccountcontrol")

  # Get the user flags and output
  $UserObjects = $ds.FindAll()
  ForEach ($oUser in $UserObjects) {
    $UserFlags = $flags.GetEnumerator() | Where-Object {
      ($_.Value -band $oUser.Properties.item("useraccountcontrol")[0]) -ne 0
    } | ForEach-Object {$_.Name}
    Write-Output (New-Object PSObject -Property @{
        Name  = $oUser.Properties.Item("Name")[0]
        Flags = $UserFlags
      })
  }
}

TranslateFlags -UserName sconnea -Verbose