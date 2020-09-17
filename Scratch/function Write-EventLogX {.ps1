function Write-EventLogX {
  [cmdletbinding()]
  param(
    [ValidateSet('Info', 'Error', 'Warning')]
    [parameter(mandatory)]
    [string]$EntryType,

    [parameter(Mandatory)]
    [string]$Message,

    [parameter()]
    [string]$LogSource = 'ApplicationX'
  )
  begin {

    $eventHash = @{
      Info    = 20000
      Warning = 20001
      Error   = 20002
    }

    $param = @{
      LogName   = 'Application'
      Source    = $LogSource
      EntryType = $EntryType
      Message   = $message
      EventID   = $eventHash[$EntryType]
    }
  }
  process {
    Write-EventLog @param
    Write-Verbose -Message $message
  }
}