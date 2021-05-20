<#
    TODO:
        - Inputfelt i menyen (Laging av skjemaer)
        - Gjør at man kan putte skjema elementer vedsiden av hverandre

    Tilstand:
        - Arbeider = [....] <Tekst>
        - Ferdig = [ ok ] <Tekst>
        - Advarsel = [warn] <Tekst>
        - Error / Feilet = [FAIL] <Tekst>

    Kommandolinjer:
        #Meny
        - New-MenuItem <Separator> <Key> <Name> <Data>
        - Show-Menu

        - Move-ConsoleCursor <CursorPosition / Management.Automation.Host.Coordinates object (from $Host.UI.RawUI.CursorPosition)> <X> <Y> <Up> <Down> <Left> <Right>
        - Clear-ConsoleLine
        *- Write-LineState <[Switch] Ok|Warn|Fail|None|Dots{Default}> <[Optional]Message> <[Optional]Next>
        *- Write-LineText <Text>

        #Skjema
        - New-Form
        *- New-FormInput
        - New-FormLabel
        *- New-FormGroup
        *- New-FormRadio
        - New-FormCheckbox
        *- New-FormButton
        - New-FormSpacer
        - New-FormSeparator -Vertical

#>
# =================================================================================================================================
#
# NAME: ConsoleUI
#
# AUTHOR : Thomas Waaler, Lærling
# DATE   :
# VERSION: 1.0.2
# COMMENT: Script til å bygge menyer og status indikator til egne script
#
# =================================================================================================================================
# CHANGELOG
# =================================================================================================================================
# DATE          VERSION     BY                        COMMENT
#               1.0.2       Thomas Waaler             Nå kan man lage simple skjemaer
# ??.??.????    1.0.1       Thomas Waaler             Lagt til muligheten til å lage menyer
# ??.??.????    1.0.0       Thomas Waaler             Første utkast
# =================================================================================================================================

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$script:SelectedMenuItem = 0
$script:SelectedFormItem = @{x = 0; y = 0 }
$formClear = $true
$menuClear = $true
$SepTxt = ""

#------------------------------------------------------------[Classes]-------------------------------------------------------------
class MenuItemList {
  [Array]$MenuItems = @()

  [void]Add([MenuItem]$MenuItem) {
    $this.MenuItems += $MenuItem
  }
}
class MenuItem {
  [String]$Key
  [String]$Name
  [ScriptBlock]$Data
  [Switch]$Separator
}

class FormList {
  [Array]$FormItems = @()
  [Array]$FormGroups = @()

  [void]Add([FormItem]$FormItem) {
    if (-not ($FormItem.KeepRight)) {
      $this.FormItems += @{ values = @() }
      $this.FormItems[$this.FormItems.Count - 1].values += $FormItem
    }
    else {
      $this.FormItems[$this.FormItems.Count - 1].values += $FormItem
    }
  }
  [void]Add([FormGroup]$FormGroup) {
    $this.FormGroups += $FormGroup
  }
}
class FormItem {
  [String]$Id
  [String]$Type
  [Switch]$KeepRight
  [Bool]$Hidden
}
class FormGroup {
  [Array]$GroupItems = @()
  [String]$Id

  [void]Add([FormItem]$FormItem) {
    $this.GroupItems += $FormItem
    $FormItem.Group = $this.Id
  }
}
class FormItemButton : FormItem {
  [String]$Text
  [ScriptBlock]$Data
  [Switch]$Disabled
}
class FormItemLabel : FormItem {
  [String]$Text
}
class FormItemRadio : FormItem {
  [String]$Label
  [String]$Group
  [Switch]$Checked
}
class FormItemInput : FormItem {
  [String]$Label
  [String]$LabelPosition
  [String]$UserInput
  [Int]$Length
    
  [void]WriteOut([String]$Text) {
        
  }
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------
<#------------------
        Meny
------------------#>
function New-Menu { $script:menuClear = $true; return [MenuItemList]::new() }

function New-MenuItem {
  param(
    [String]$Key,
    [String]$Name,
    [ScriptBlock]$Data,
    [Switch]$Separator
  )

  $MenuItem = [MenuItem]::new()
  $MenuItem.Key = $Key
  $MenuItem.Name = $Name
  $MenuItem.Data = $Data
  $MenuItem.Separator = $Separator

  return $MenuItem
}

function Show-MenuExecute {
  param(
    [MenuItemList]$Menu,
    [String]$Title
  )
  if ($menuClear) { Clear-Host; $script:menuClear = $false }
  # Clear-Host

  $StartCursorPos = $Host.UI.RawUI.CursorPosition
  $HeaderTxt = "===== [ $Title ] "
  $HeaderTxtLength = $HeaderTxt.Length
  for ($i = 0; $i -lt ($Host.UI.RawUI.WindowSize.Width - $HeaderTxtLength); $i++) {
    $HeaderTxt += "="
  }
  Write-Host $HeaderTxt
  # Write-Host "===== [ $Title ] =================================================="
  for ($i = 0; $i -lt $Menu.MenuItems.Count; $i++) {
    if ($Menu.MenuItems[$i].Separator) {
      $SepTxt = ""
      for ($j = 0; $j -lt $Host.UI.RawUI.WindowSize.Width; $j++) {
        $SepTxt += "-"
      }
      Write-Host $SepTxt
    }
    else {
      if ($SelectedMenuItem -eq $i) {
        Write-Host "$($Menu.MenuItems[$i].Key). $($Menu.MenuItems[$i].Name)" -BackgroundColor White -ForegroundColor DarkBlue
      }
      else {
        Write-Host "$($Menu.MenuItems[$i].Key). $($Menu.MenuItems[$i].Name)"
      }
    }
  }

  $continue = $true
  $FooterTxt = ""
  for ($i = 0; $i -lt $Host.UI.RawUI.WindowSize.Width; $i++) {
    $FooterTxt += "="
  }
  Write-Host $FooterTxt
  Write-Host "INFO: Use arrows up/down, or use itemkey" -ForegroundColor Cyan
  $CursorPos = $Host.UI.RawUI.CursorPosition
  Write-Host "Action: " -NoNewline
  while ($continue) {
    if ([console]::KeyAvailable) {
      $Host.UI.RawUI.CursorPosition = $CursorPos
      Write-Host "Action: " -NoNewline
      $x = [System.Console]::ReadKey($true)

      switch ($x.key) {
        "Enter" {
          if ($Menu.MenuItems[$SelectedMenuItem].Data -ne $null) {
            & $Menu.MenuItems[$SelectedMenuItem].Data
            $script:menuClear = $true
            $continue = $false
            $Host.UI.RawUI.CursorPosition = $StartCursorPos
            Show-MenuExecute -Menu $Menu -Title $Title
          }
        }
        "DownArrow" {
          if (-not (($SelectedMenuItem + 1) -gt ($Menu.MenuItems.Count - 1))) {
            $script:SelectedMenuItem++
            $wrong = $true
            while ($wrong) {
              if ($Menu.MenuItems[$SelectedMenuItem].Separator) {
                $script:SelectedMenuItem++
              }
              else {
                $wrong = $false
              }
            }
            $continue = $false
            $Host.UI.RawUI.CursorPosition = $StartCursorPos
            Show-MenuExecute -Menu $Menu -Title $Title
          }
          else {
            $script:SelectedMenuItem = 0
            $continue = $false
            $Host.UI.RawUI.CursorPosition = $StartCursorPos
            Show-MenuExecute -Menu $Menu -Title $Title
          }
        }
        "UpArrow" {
          if (-not (($SelectedMenuItem - 1) -lt 0)) {
            $script:SelectedMenuItem--
            $wrong = $true
            while ($wrong) {
              if ($Menu.MenuItems[$SelectedMenuItem].Separator) {
                $script:SelectedMenuItem--
              }
              else {
                $wrong = $false
              }
            }
            $continue = $false
            $Host.UI.RawUI.CursorPosition = $StartCursorPos
            Show-MenuExecute -Menu $Menu -Title $Title
          }
          else {
            $script:SelectedMenuItem = $Menu.MenuItems.Count - 1
            $continue = $false
            $Host.UI.RawUI.CursorPosition = $StartCursorPos
            Show-MenuExecute -Menu $Menu -Title $Title
          }
        }
        default {
          for ($i = 0; $i -lt $Menu.MenuItems.Count; $i++) {
            $xKey = $x.key.ToString()
            if ($x.key -like "NumPad*") { $xKey = $xKey.SubString(6) }
            elseif ($x.key -like "D*") { $xKey = $xKey.SubString(1) }

            if ($xKey -like $Menu.MenuItems[$i].key) {
              # $Host.UI.RawUI.CursorPosition = $CursorPos
              & $Menu.MenuItems[$i].Data
              $continue = $false
              $Host.UI.RawUI.CursorPosition = $StartCursorPos
              Show-MenuExecute -Menu $Menu -Title $Title
            }
          }
        }
      }
    }
  }
}

<#------------------
        Form
------------------#>
function New-Form { $script:formClear = $true; return [FormList]::new() }

function New-FormSeparator {
  $FormItem = [FormItem]::new()
  $FormItem.Type = "Separator"

  return $FormItem
}

function New-FormSpacer {
  $FormItem = [FormItem]::new()
  $FormItem.Type = "Spacer"

  return $FormItem
}

function New-FormButton {
  param(
    [String]$Text,
    [ScriptBlock]$Data,
    [Switch]$Disabled,
    [Switch]$KeepRight,
    [Boolean]$Hidden = $false
  )

  $FormItem = [FormItemButton]::new()
  $FormItem.Text = $Text
  $FormItem.Type = "Button"
  $FormItem.Data = $Data
  $FormItem.Disabled = $Disabled
  $FormItem.KeepRight = $KeepRight
  $FormItem.Hidden = $Hidden

  return $FormItem
}

function New-FormRadio {
  param(
    [String]$Id,
    [String]$Label,
    [Switch]$Checked = $false,
    [Switch]$KeepRight,
    [Boolean]$Hidden = $false
  )

  $FormItem = [FormItemRadio]::new()
  $FormItem.Id = $Id
  $FormItem.Type = "Radio"
  $FormItem.Label = $Label
  $FormItem.Checked = $Checked
  $FormItem.KeepRight = $KeepRight
  $FormItem.Hidden = $Hidden

  return $FormItem
}

function New-FormInput {
  param(
    [String]$Id,
    [String]$Label,
    [ValidateSet("Left", "Top")]$LabelPosition = "Left",
    [Int]$Length = 15,
    [Switch]$KeepRight,
    [Boolean]$Hidden = $false
  )

  $FormItem = [FormItemInput]::new()
  $FormItem.Id = $Id
  $FormItem.Type = "Input"
  $FormItem.Label = $Label
  $FormItem.LabelPosition = $LabelPosition
  $FormItem.Length = $Length
  $FormItem.KeepRight = $KeepRight
  $FormItem.Hidden = $Hidden

  return $FormItem
}

function New-FormLabel {
  param(
    [String]$Text,
    [Boolean]$Hidden = $false
  )

  $FormItem = [FormItemLabel]::new()
  $FormItem.Text = $Text
  $FormItem.Type = "Label"
  $FormItem.Hidden = $Hidden

  return $FormItem
}

function New-FormGroup {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [ValidateNotNullOrEmpty()]
    [String]$Id
  )

  $FormGroup = [FormGroup]::new()
  $FormGroup.Id = $Id

  return $FormGroup
}

function Show-FormExecute {
  param(
    [FormList]$Form,
    [String]$Title
  )
  if ($formClear) { Clear-Host; $script:formClear = $false }
  # Clear-Host

  $StartCursorPos = $Host.UI.RawUI.CursorPosition
  $HeaderTxt = "===== [ $Title ] "
  $HeaderTxtLength = $HeaderTxt.Length
  for ($i = 0; $i -lt ($Host.UI.RawUI.WindowSize.Width - $HeaderTxtLength); $i++) {
    $HeaderTxt += "="
  }
  Write-Host $HeaderTxt
  for ($y = 0; $y -lt $Form.FormItems.Count; $y++) {
    for ($x = 0; $x -lt $Form.FormItems[$y].values.Count; $x++) {
      switch ($Form.FormItems[$y].values[$x].Type) {
        "Separator" { Write-Host $script:SepTxt }
        "Spacer" { Write-Host "" }
        "Label" { if (-not $Form.FormItems[$y].values[$x].Hidden) { Write-Host "$($Form.FormItems[$y].values[$x].Text)" -ForegroundColor Gray } }
        "Input" {
          $UserInput = $Form.FormItems[$y].values[$x].UserInput
          if ($x -gt 0) { $Host.UI.RawUI.CursorPosition = $EndElementCursorPos; Write-Host "     " -NoNewline }

          if ($SelectedFormItem.x -eq $x -and $SelectedFormItem.y -eq $y) {
            Write-Host "$($Form.FormItems[$y].values[$x].Label): " -NoNewline

            Write-Host "[$UserInput" -NoNewline -BackgroundColor White -ForegroundColor DarkBlue
            $restTxt = ""
            for ($j = 0; $j -lt ($Form.FormItems[$y].values[$x].Length - $UserInput.Length); $j++) { $restTxt += "_" }
            Write-Host "$restTxt]" -BackgroundColor White -ForegroundColor DarkBlue -NoNewline
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
          else {
            Write-Host "$($Form.FormItems[$y].values[$x].Label): " -NoNewline

            Write-Host "[$UserInput" -NoNewline
            $restTxt = ""
            for ($j = 0; $j -lt ($Form.FormItems[$y].values[$x].Length - $UserInput.Length); $j++) { $restTxt += "_" }
            Write-Host "$restTxt]" -NoNewline
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
        }
        "Button" {
          if ($x -gt 0) { $Host.UI.RawUI.CursorPosition = $EndElementCursorPos; Write-Host "   " -NoNewline }

          if ($SelectedFormItem.x -eq $x -and $SelectedFormItem.y -eq $y) {
            Write-Host "║ $($Form.FormItems[$y].values[$x].Text) ║" -NoNewline -BackgroundColor White -ForegroundColor DarkBlue
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
          else {
            Write-Host "║ $($Form.FormItems[$y].values[$x].Text) ║" -NoNewline
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
        }
        "Radio" {
          if ($x -gt 0) { $Host.UI.RawUI.CursorPosition = $EndElementCursorPos; Write-Host "   " -NoNewline }
          if ($Form.FormItems[$y].values[$x].Checked) { $CheckRadio = "(√)" } else { $CheckRadio = "(O)" }

          if ($SelectedFormItem.x -eq $x -and $SelectedFormItem.y -eq $y) {
            Write-Host "$($Form.FormItems[$y].values[$x].Label): " -NoNewline
            Write-Host "$CheckRadio" -NoNewline -BackgroundColor White -ForegroundColor DarkBlue
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
          else {
            Write-Host "$($Form.FormItems[$y].values[$x].Label): $CheckRadio" -NoNewline
            $EndElementCursorPos = $Host.UI.RawUI.CursorPosition
            Write-Host ""
          }
        }
      }
    }
  }

  $FooterTxt = ""
  for ($i = 0; $i -lt $Host.UI.RawUI.WindowSize.Width; $i++) {
    $FooterTxt += "="
  }
  Write-Host $FooterTxt

  $continue = $true
  $CursorPos = $Host.UI.RawUI.CursorPosition
  while ($continue) {
    if ([console]::KeyAvailable) {
      $Host.UI.RawUI.CursorPosition = $CursorPos
      $x = [System.Console]::ReadKey($true)

      switch ($x.key) {
        "LeftArrow" {
          if (-not (($SelectedFormItem.x - 1) -lt 0)) {
            $script:SelectedFormItem.x--
          }
          else {
            $script:SelectedFormItem.x = ($Form.FormItems[$SelectedFormItem.y].values.Count - 1)
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        "RightArrow" {
          if (-not (($SelectedFormItem.x + 1) -gt ($Form.FormItems[$SelectedFormItem.y].values.Count - 1))) {
            $script:SelectedFormItem.x++
          }
          else {
            $script:SelectedFormItem.x = 0
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        "DownArrow" {
          if (-not (($SelectedFormItem.y + 1) -gt ($Form.FormItems.Count - 1))) {
            $script:SelectedFormItem.y++

            $wrong = $true
            while ($wrong) {
              if ($Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Separator" -or $Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Label" -or $Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Spacer" -or $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x] -eq $null) {
                if (-not (($SelectedFormItem.y + 1) -gt ($Form.FormItems.Count - 1))) {
                  $script:SelectedFormItem.y++
                }
                else {
                  $script:SelectedFormItem.y = 0
                }
              }
              else {
                $wrong = $false
              }
            }
          }
          else {
            $script:SelectedFormItem.y = 0
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        "UpArrow" {
          if (-not (($SelectedFormItem.y - 1) -lt 0)) {
            $script:SelectedFormItem.y--

            $wrong = $true
            while ($wrong) {
              if ($Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Separator" -or $Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Label" -or $Form.FormItems[$SelectedFormItem.y].values[0].Type -eq "Spacer" -or $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x] -eq $null) {
                if (-not (($SelectedFormItem.y - 1) -lt 0)) {
                  $script:SelectedFormItem.y--
                }
                else {
                  $script:SelectedFormItem.y = ($Form.FormItems.Count - 1)
                }
              }
              else {
                $wrong = $false
              }
            }
          }
          else {
            $script:SelectedFormItem.y = ($Form.FormItems.Count - 1)
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        "Enter" {
          if ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Type -eq "Button") {
            $script:formClear = $true

            & $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Data
            $script:SelectedFormItem.x = 0
            $script:SelectedFormItem.y = 0
          }
          elseif ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Type -eq "Radio") {
            # Hvis den tilhører en gruppe eller ikke
            if ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Group.Length -gt 0) {
              # Hvis den er sjekket eller ikke
              if (!$Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked) {
                for ($i = 0; $i -lt $Form.FormGroups.Count; $i++) {
                  # Sjekk om den finner samme gruppe som radio knappen er i
                  if ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Group -eq $Form.FormGroups[$i].Id) {
                    # Gå igjennom alle i gruppen og sett dem til checked=false
                    for ($j = 0; $j -lt $Form.FormGroups[$i].GroupItems.Count; $j++) {
                      $Form.FormGroups[$i].GroupItems[$j].Checked = $false
                    }
                  }
                }
                $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked = $true
              }
              else {
                $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked = !$Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked
              }
            }
            else {
              $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked = !$Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Checked
            }
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        "Backspace" {
          if ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Type -eq "Input") {
            $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].UserInput = $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].UserInput.Substring(0, $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].UserInput.Length - 1)
          }

          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
        default {
          if ($Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].Type -eq "Input") {
            if ($x.Key -ne "Tab") {
              $Form.FormItems[$SelectedFormItem.y].values[$SelectedFormItem.x].UserInput += $x.KeyChar
            }
          }
                    
          $continue = $false
          $Host.UI.RawUI.CursorPosition = $StartCursorPos
          Show-FormExecute -Form $Form -Title $Title
        }
      }
    }
  }
}

<#------------------
    Konsollstatus
------------------#>
function Write-LineText {
  param(
    [String]$Text
  )

  $Global:ActionText = $Text
}

function Write-LineState {
  param(
    [Switch]$Ok,
    [Switch]$Warn,
    [Switch]$Fail,
    [Switch]$None,
    [Switch]$Dots,
    [Switch]$Next,
    [String]$Message
  )

  $CursorPos = $Host.UI.RawUI.CursorPosition
  Write-Host "[" -NoNewline -ForegroundColor White
  if ($Ok) {
    Write-Host " ok " -NoNewline -ForegroundColor Green
  }
  elseif ($Warn) {
    Write-Host "warn" -NoNewline -ForegroundColor Yellow
  }
  elseif ($Fail) {
    Write-Host "FAIL" -NoNewline -ForegroundColor Red
  }
  elseif ($None) {
    Write-Host "    " -NoNewline
  }
  elseif ($Message.Length -gt 0) {
    Write-Host $Message -NoNewline -ForegroundColor Cyan
  }
  else {
    Write-Host "...." -NoNewline -ForegroundColor White
  }
  Write-Host "] $ActionText" -ForegroundColor White

  if (-not ($Next)) {
    $Host.UI.RawUI.CursorPosition = $CursorPos
  }
}

function CheckScriptBlock {
  param(
    [String]$Text,
    [ScriptBlock]$Data
  )

  Write-LineText -Text $Text
  try {
    Write-LineState

    & $Data

    Write-LineState -Ok -Next
  }
  catch {
    Write-LineState -Fail -Next
    Write-Host "$($_.ToString())" -ForegroundColor Yellow
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
# Sjekk om de kjører i ISE eller ikke
if ($psise -ne $null) {
  Write-Warning "ConsoleUI can not be run in ISE.`nPlease use PowerShell console!"
  break
}
for ($j = 0; $j -lt $Host.UI.RawUI.WindowSize.Width; $j++) {
  $script:SepTxt += "-"
}


$ErrorActionPreference = "Stop"

# Importerer LO ConsoleStatus


function Create-MainMenu() {
  # Create a new menu
  $menu = New-Menu

  # Add MenuItems to the menu
  $menu.Add( (New-MenuItem -Key "1" -Name "Show form" -Data { Create-TestForm }) )
  $menu.Add( (New-MenuItem -Key "2" -Name "Run scriptblock check" -Data { Run-Check }) )
  #$menu.Add( (New-MenuItem -Separator) )
  $menu.Add( (New-MenuItem -Key "0" -Name "Exit" -Data { exit }) )

  # Start menu
  Show-MenuExecute -Title "Test menu" -Menu $menu
}

function Create-TestForm() {
  # Create a Form-Object
  $form = New-Form

  # Create a Group and add two Radio-Objects to it
  $genderGroup = New-FormGroup -Id "genderGroup"
  $genderMale = New-FormRadio -Label "Male"
  $genderFemale = New-FormRadio -Label "Female"
  $genderGroup.Add($genderMale)
  $genderGroup.Add($genderFemale)

  # Add FormItems to the form
  $form.Add( (New-FormInput -Label "Firstname") )
  $form.Add( (New-FormInput -Label "Lastname ") )
  $form.Add( (New-FormSpacer) )
  $form.Add($genderGroup)
  $form.Add($genderMale)
  $form.Add($genderFemale)
  $form.Add( (New-FormSeparator) )
  $form.Add( (New-FormButton -Text "Send data" -Data { Create-MainMenu }) )

  # Start form
  Show-FormExecute -Title "Test Form" -Form $form
}

function Run-Check() {
  Write-Host ""
    
  CheckScriptBlock -Text "Counting to 100 000 000" -Data {
    for ($i = 0; $i -lt 100000000; $i++) {
    }
  }

  CheckScriptBlock -Text "Finding something cool" -Data {
    for ($i = 0; $i -lt 100000; $i++) {
    }
  }

  CheckScriptBlock -Text "Getting user informasjon" -Data {
    for ($i = 0; $i -lt 100000; $i++) {
      asdasdqw
    }
  }

  # Checking a scriptblock with a try catch
  Write-LineText -Text "Counting to 100 000 000"
  try {
    Write-LineState

    for ($i = 0; $i -lt 100000000; $i++) {
    }

    Write-LineState -Ok -Next
  }
  catch {
    Write-LineState -Fail -Next
    Write-Host "$($_.ToString())" -ForegroundColor Yellow
  }

  Write-Host ""
  Write-Host "Press enter to go back..."
  Read-Host
}

Create-MainMenu