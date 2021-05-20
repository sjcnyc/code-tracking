

# define [AutoLearn()]
class AutoLearnAttribute : System.Management.Automation.ArgumentTransformationAttribute {
  # define path to store hint lists
  [string]$Path = "$env:temp\hints"

  # define ID to manage multiple hint lists
  [string]$Id = 'default'

  # define prefix character used to delete the hint list
  [char]$ClearKey = '!'

  # define parameterless constructor
  AutoLearnAttribute() : base()
  {}

  # define constructor with parameter for ID
  AutoLearnAttribute([string]$Id) : base() {
    $this.Id = $Id
  }
    
  # Transform() is called whenever there is a variable or parameter assignment, 
  # and returns the value that is actually assigned
  [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
    # make sure the folder with hints exists
    $exists = Test-Path -Path $this.Path
    if (!$exists) { $null = New-Item -Path $this.Path -ItemType Directory }

    # create a filename for hint list
    $filename = '{0}.hint' -f $this.Id
    $hintPath = Join-Path -Path $this.Path -ChildPath $filename
        
    # use a hash table to keep hint list
    $hints = @{}

    # read hint list if it exists
    $exists = Test-Path -Path $hintPath
    if ($exists) {
      Get-Content -Path $hintPath -Encoding Default |
      # remove leading and trailing blanks
      ForEach-Object { $_.Trim() } |
      # remove empty lines
      Where-Object { ![string]::IsNullOrEmpty($_) } |
      # add to hash table
      ForEach-Object {
        # value is not used, set it to $true
        $hints[$_] = $true
      }
    }

    # does the user input start with the clearing key?
    if ($inputData.StartsWith($this.ClearKey)) {
      # remove the prefix
      $inputData = $inputData.SubString(1)

      # clear the hint list
      $hints.Clear()
    }

    # add new value to hint list
    if (![string]::IsNullOrWhiteSpace($inputData)) {
      $hints[$inputData] = $true
    }
    # save hints list
    $hints.Keys | Sort-Object | Set-Content -Path $hintPath -Encoding Default 
        
    # return the user input (if there was a clearing key at its start,
    # it is now stripped)
    return $inputData
  }
}

# define [AutoComplete()]
class AutoCompleteAttribute : System.Management.Automation.ArgumentCompleterAttribute {
  # define path to store hint lists
  [string]$Path = "$env:temp\hints"

  # define ID to manage multiple hint lists
  [string]$Id = 'default'
  
  # define parameterless constructor
  AutoCompleteAttribute() : base([AutoCompleteAttribute]::_createScriptBlock($this)) 
  {}

  # define constructor with parameter for ID
  AutoCompleteAttribute([string]$Id) : base([AutoCompleteAttribute]::_createScriptBlock($this)) {
    $this.Id = $Id
  }

  # create a static helper method that creates the script block that the base constructor needs
  # this is necessary to be able to access the argument(s) submitted to the constructor
  # the method needs a reference to the object instance to (later) access its optional parameters
  hidden static [ScriptBlock] _createScriptBlock([AutoCompleteAttribute] $instance) {
    $scriptblock = {
      # receive information about current state
      param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   
      # create filename for hint list
      $filename = '{0}.hint' -f $instance.Id
      $hintPath = Join-Path -Path $instance.Path -ChildPath $filename
        
      # use a hash table to keep hint list
      $hints = @{}

      # read hint list if it exists
      $exists = Test-Path -Path $hintPath
      if ($exists) {
        Get-Content -Path $hintPath -Encoding Default |
        # remove leading and trailing blanks
        ForEach-Object { $_.Trim() } |
        # remove empty lines
        Where-Object { ![string]::IsNullOrEmpty($_) } |
        # filter completion items based on existing text
        Where-Object { $_.LogName -like "$wordToComplete*" } | 
        # create argument completion results
        ForEach-Object { 
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
      }
    }.GetNewClosure()
    return $scriptblock
  }
}

function Connect-MyServer {
  param
  (
    [string]
    [Parameter(Mandatory)]
    # auto-learn user names to user.hint
    [AutoLearn('user')]
    # auto-complete user names from user.hint
    [AutoComplete('user')]
    $UserName,

    [string]
    [Parameter(Mandatory)]
    # auto-learn computer names to server.hint
    [AutoLearn('server')]
    # auto-complete computer names from server.hint
    [AutoComplete('server')]
    $ComputerName
  )

  "Hello $Username, connecting you to $ComputerName"
}



Connect-MyServer -UserName "sconnea" -ComputerName "kohi-tiny"

Connect-MyServer -UserName sean -ComputerName storage