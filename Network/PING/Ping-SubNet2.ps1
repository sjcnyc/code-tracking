﻿1..255 | %{$result = Test-Connection -ComputerName "162.49.2.$_" -Count 1 -quiet ; if ($result){Write-host "162.49.2.$_ `t UP" -ForegroundColor Green}
else {Write-host "162.49.2.$_ `t DOWN" -ForegroundColor RED}}