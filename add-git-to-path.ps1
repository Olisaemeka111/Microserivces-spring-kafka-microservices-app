# Script to add Git to the system PATH
Write-Host "Adding Git to the system PATH..."

# Common Git installation locations
$possibleGitPaths = @(
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\bin",
    "C:\Program Files (x86)\Git\cmd",
    "C:\Program Files (x86)\Git\bin",
    "C:\Git\cmd",
    "C:\Git\bin"
)

# Find Git installation
$gitPath = $null
foreach ($path in $possibleGitPaths) {
    if (Test-Path $path) {
        $gitPath = $path
        Write-Host "Found Git at: $gitPath"
        break
    }
}

# If Git wasn't found in common locations, search for it
if ($null -eq $gitPath) {
    Write-Host "Searching for Git installation..."
    $gitExe = Get-ChildItem -Path "C:\" -Filter "git.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $gitExe) {
        $gitPath = Split-Path -Parent $gitExe.FullName
        Write-Host "Found Git at: $gitPath"
    }
}

# If Git is still not found, prompt user
if ($null -eq $gitPath) {
    Write-Host "Git installation not found in common locations."
    $manualPath = Read-Host "Please enter the full path to your Git installation (e.g., C:\Program Files\Git\cmd)"
    if (Test-Path $manualPath) {
        $gitPath = $manualPath
    } else {
        Write-Host "The specified path does not exist. Aborting."
        exit 1
    }
}

# Get current PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")

# Check if Git is already in PATH
if ($currentPath -like "*$gitPath*") {
    Write-Host "Git is already in your PATH."
} else {
    # Add Git to PATH
    $newPath = "$currentPath;$gitPath"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "Git has been added to your PATH."
    Write-Host "You may need to restart your terminal or computer for changes to take effect."
}

# Verify Git is accessible
Write-Host "`nVerifying Git installation..."
try {
    $gitVersion = & "$gitPath\git.exe" --version
    Write-Host "Git is now accessible: $gitVersion"
} catch {
    Write-Host "Error verifying Git installation: $_"
}

Write-Host "`nGit has been added to your PATH. Please restart your terminal or command prompt for the changes to take effect."
