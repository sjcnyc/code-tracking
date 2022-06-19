$invokeExpressionSplat = @{
    Command = "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1')  -useMSI -EnablePSRemoting"
}

Invoke-Expression @invokeExpressionSplat