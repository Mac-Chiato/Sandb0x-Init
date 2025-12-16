Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value "0"
echo "" | CiTool.exe -r | out-null

function Get-UserInputWithTimeout {
    [CmdletBinding()]
    param(
        [int]$Seconds = 5,
        [string]$Prompt = "Please enter something",
        [switch]$Silent  # if you don't want the prompt line
    )

    # Write prompt
    if (-not $Silent) {
        Write-Host "$Prompt (waiting $Seconds seconds):"
    }

    # Prepare timer and buffer
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $buffer = New-Object System.Text.StringBuilder

    # Helper: write a single character to the console (no newline)
    function Write-Char([char]$ch) {
        [Console]::Write($ch)
    }

    # Read loop: poll for keys until Enter or timeout
    while ($sw.Elapsed.TotalSeconds -lt $Seconds) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)

            switch ($key.Key) {
                'Enter' {
                    # Finish on Enter
                    [Console]::WriteLine()
                    return $buffer.ToString()
                }
                'Backspace' {
                    if ($buffer.Length -gt 0) {
                        # Remove last char from buffer and update console
                        $buffer.Length = $buffer.Length - 1
                        # Erase last char visually: backspace + space + backspace
                        Write-Char "`b"; Write-Char " "; Write-Char "`b"
                    }
                }
                default {
                    # Only record printable characters
                    if (-not $key.Modifiers -and $key.KeyChar -ne 0) {
                        $buffer.Append($key.KeyChar) | Out-Null
                        Write-Char $key.KeyChar
                    }
                    # Ignore modifier/arrow/function keys (KeyChar = 0)
                }
            }
        } else {
            Start-Sleep -Milliseconds 50  # small wait to avoid spinning CPU
        }
    }

    # Timeout reached
    if ($buffer.Length -gt 0) {
        [Console]::WriteLine()
        return $buffer.ToString()
    } else {
        Write-Host "No input received within $Seconds seconds. Continuing..."
        return $null
    }
}

# --- Example usage ---
$userInput = Get-UserInputWithTimeout -Seconds 10 -Prompt "Press a key to cancel Winget & MSSTORE installation"
if ($null -ne $userInput) {
    Write-Host "You entered: $userInput"
} else {
    Write-Host "Proceeding without user input."
		
	Write-Host "Installing winget"
	$progressPreference = 'silentlyContinue'
	Write-Host "Installing WinGet PowerShell module from PSGallery..."
	Install-PackageProvider -Name NuGet -Force | Out-Null
	Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
		
	Write-Host "Continue Startup"
	powershell.exe -executionpolicy unrestricted -File $env:Userprofile\Desktop\scripts\startup.ps1
}
Write-Host "finished"
$dots = {
    for ($i = 0; $i -lt 3; $i++) {
      Write-Host "." -NoNewline
      Start-Sleep -Milliseconds 500
      Write-Host "`b`b`b   `b`b`b   `b`b`b" -NoNewline
    }
  }
