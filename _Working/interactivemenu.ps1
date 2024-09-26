Import-Module .\InteractiveMenu\InteractiveMenu.psd1

# Choose menu answers
$answers = @(
    Get-InteractiveChooseMenuOption `
        -Label "Active Directory" `
        -Value  "1" `
        -Info "Remove computer from Active Directory"
    Get-InteractiveChooseMenuOption `
        -Label "SCCM Collection" `
        -Value "2" `
        -Info "Remove computer from SCCM Collection"
    Get-InteractiveChooseMenuOption `
        -Label "Both" `
        -Value "3" `
        -Info "remove computer from both Active Directory and SCCM Collection"
)

$options = @{
    MenuInfoColor = [ConsoleColor]::DarkYellow;
    QuestionColor = [ConsoleColor]::Magenta;
    HelpColor = [ConsoleColor]::Cyan;
    ErrorColor = [ConsoleColor]::DarkRed;
    HighlightColor = [ConsoleColor]::DarkGreen;
    OptionSeparator = "      ";
}

$answer = Get-InteractiveMenuChooseUserSelection -Question "Select action" -Answers $answers -Options $options

Write-Host "Answer: $answer"

