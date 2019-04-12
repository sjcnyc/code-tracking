function Main-Menu {
    Clear-host
    do {
        Write-Host "1. Menu 1 `n2. Menu 2 `n3. Menu 3"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {sub-menu1}
            "2" {sub-menu2}
            "3" {sub-menu3}
        }
    }
    until (1..3 -contains $menuresponse) 
}

function sub-menu1 {
    Clear-Host
    do {
        Write-Host "1. Option 1 `n2. Option 2 `n3. Return to Main Menu"
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {sub-menu1}
            "2" {sub-menu1}
            "3" {Main-Menu}
        }
    }
    until (1..3 -contains $menuresponse)
}

Main-Menu