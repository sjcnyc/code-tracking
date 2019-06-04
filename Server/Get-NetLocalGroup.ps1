#requires -Version 2
Function Get-NetLocalGroup {
  [cmdletbinding()]

  Param(
    [Parameter(Position = 0)]
    [ValidateNotNullorEmpty()]
    [object[]]$Computername = $env:computername,
    [ValidateNotNullorEmpty()]
    [string]$Group = 'Administrators',
    [switch]$Asjob
  )
  
  Write-Verbose -Message "Getting members of local group $Group"

  #define the scriptblock
  $sb = {
    Param([string]$Name = 'Administrators')
    $members = net.exe localgroup $Name |
    Where-Object -FilterScript {$_ -AND $_ -notmatch 'command completed successfully'} | 
    Select-Object -Skip 4
    New-Object -TypeName PSObject -Property @{
      Computername = $env:computername
      Group        = $Name
      Members      = ($members | Out-String).Trim()
    }
  } #end scriptblock
  
  #define a parameter hash table for splatting
  $paramhash = @{
    Scriptblock      = $sb
    HideComputername = $True
    ArgumentList     = $Group
  }

  if ($Computername[0] -is [management.automation.runspaces.pssession]) {$paramhash.Add('Session',$Computername)}
  else {$paramhash.Add('Computername',$Computername)}
  
  if ($Asjob) {
    Write-Verbose -Message 'Running as job'
    $paramhash.Add('AsJob',$True)
  }
  
  #run the command
  Invoke-Command @paramhash | Select-Object * -ExcludeProperty RunspaceID
} #end Get-NetLocalGroup
