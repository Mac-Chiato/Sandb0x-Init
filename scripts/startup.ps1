
Write-Host "Installing MS Store"
powershell.exe -executionpolicy unrestricted -File $env:Userprofile\Desktop\scripts\Install-Microsoft-Store.ps1

Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Start-Sleep -Seconds 5
Repair-WinGetPackageManager -AllUsers
Write-Host "Done."

Write-Host "Installing Windows Notepad from MS Store"
winget install 9MSMLRH6LZF3 --accept-source-agreements --accept-package-agreements

Write-Host "Finished..."
Start-Sleep -Seconds 10