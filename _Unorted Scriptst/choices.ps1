$choices = @(
    ("&Quit", "Quit"),
    ("0&1-January", "01-January OU"),
    ("0&2-February", "02-February OU"),
    ("0&3-March", "03-March OU"),
    ("0&4-April", "04-April OU"),
    ("0&5-May", "05-May OU"),
    ("0&6-June", "06-June OU"),
    ("0&7-July", "07-July OU"),
    ("0&8-August", "08-August OU"),
    ("0&9-September", "09-September OU"),
    ("1&0-October", "10-October OU"),
    ("11-&November", "11-November OU"),
    ("12-&December", "12-December OU")
)
$choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]
for ($i = 0; $i -lt $choices.length; $i++) {
    $choicedesc.Add((New-Object System.Management.Automation.Host.ChoiceDescription $choices[$i] ) ) 
}
$Host.ui.PromptForChoice($caption, $message, $choicedesc, 0)