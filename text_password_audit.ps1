# Path to audit 
$TargetFolder = "C:\path_of_folder_with_files_to_audit"

# Path to output log
$LogFile = "C:\path_of_file_to_store_logs"

# Dictionary words list (expand as needed) that triggers password check
$Dictionary = @("admin", "user", "test", "password", "secret", "login", "hello", "welcome", "data")

# Common code-like commands (expand as needed) that mitigate password check
$CodeCommands = @("echo", "import", "select", "cd", "mkdir", "curl", "function", "if", "else", "try", "catch", "def", "print", "var", "let", "const")

# Initialize log
"Audit started at $(Get-Date)`n" | Out-File -FilePath $LogFile

# Get all .txt files
$Files = Get-ChildItem -Path $TargetFolder -Filter *.txt -Recurse -ErrorAction SilentlyContinue

foreach ($File in $Files) {
    try {
        $Lines = Get-Content -Path $File.FullName -ErrorAction Stop
        for ($i = 0; $i -lt $Lines.Count; $i++) {
            $Line = $Lines[$i]

            # Check for keywords
            foreach ($Keyword in @("password", "username", "secret")) {
                if ($Line -match "(?i)\b$Keyword\b") {
                    $NextLine = if ($i + 1 -lt $Lines.Count) { $Lines[$i + 1].Trim() } else { "" }
                    $LowerNextLine = $NextLine.ToLower()

                    $RiskLevel = "Unknown"

                    if ($NextLine -eq "") {
                        $RiskLevel = "Low (No content found on next line)"
                    }
                    elseif ($Dictionary -contains $LowerNextLine -and $CodeCommands -contains $LowerNextLine) {
                        $RiskLevel = "Low"
                    }
                    elseif ($Dictionary -contains $LowerNextLine) {
                        $RiskLevel = "Medium"
                    }
                    elseif ($CodeCommands -contains $LowerNextLine) {
                        $RiskLevel = "Low"
                    }
                    else {
                        $RiskLevel = "High"
                    }

                    # Log result with line number
                    Add-Content -Path $LogFile -Value "[$RiskLevel] - $Keyword found in $($File.FullName) at line $($i + 1)"
                    Add-Content -Path $LogFile -Value " Line $($i + 1): $Line"
                    Add-Content -Path $LogFile -Value " Line $($i + 2): $NextLine`n"
                }
            }
        }
    } catch {
        Add-Content -Path $LogFile -Value "ERROR reading file $($File.FullName): $_"
    }
}

"Audit completed at $(Get-Date)" | Out-File -FilePath $LogFile -Append
Write-Output "Audit complete. See $LogFile for results."
