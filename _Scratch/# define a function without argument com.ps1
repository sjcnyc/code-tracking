# define a function without argument completer
function Start-Software {
  param(
    [Parameter(Mandatory)]
    [string]
    $Path
  )

  Start-Process -FilePath $Path
}

# define the code used for completing application paths
$code = {

}

# calculate the completion values once, and reuse the values later
# store results in a script-global variable
$script:applicationCompleter = & {
  # get registered applications from registry
  $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\*"

  [System.Collections.Generic.List[string]]$list =
  Get-ItemProperty -Path $key |
  Select-Object -ExpandProperty '(Default)' -ErrorAction Ignore

  # add applications found by Get-Command
  [System.Collections.Generic.List[string]]$commands =
  Get-Command -CommandType Application |
  Select-Object -ExpandProperty Source
  $list.AddRange($commands)

  # add descriptions and compose completionresult entries
  $list |
  # remove empty paths
  Where-Object { $_ } |
  # remove quotes and turn to lower case
  ForEach-Object { $_.Replace('"', '').Trim().ToLower() } |
  # remove duplicate paths
  Sort-Object -Unique |
  ForEach-Object {
    # skip files that do not exist
    if ( (Test-Path -Path $_)) {
      # get file details
      $file = Get-Item -Path $_
      # quote path if it has spaces
      $path = $_
      if ($path -like '* *') { $path = "'$path'" }
      # make sure tooltip is not null
      $tooltip = [string]$file.VersionInfo.FileDescription
      if ([string]::IsNullOrEmpty($tooltip)) { $tooltip = $file.Name }
      # compose completion result
      [Management.Automation.CompletionResult]::new(
        # complete path
        $path,
        # show friendly text in IntelliSense menu
        ('{0} ({1})' -f $tooltip, $file.Name),
        # use file icon
        'ProviderItem',
        # show file description
        $tooltip
      )
    }
  }
}

# instead of complex code, simply return the cached results when needed
$code = { $script:applicationCompleter }

# tie the completer code to all applicable parameters of own or foreign commands
Register-ArgumentCompleter -CommandName Start-Software -ParameterName Path -ScriptBlock $code
Register-ArgumentCompleter -CommandName Start-Process -ParameterName FilePath -ScriptBlock $code

Start-Process