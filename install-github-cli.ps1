# Script to install GitHub CLI and authenticate
Write-Host "Installing GitHub CLI and setting up authentication..."

# Check if GitHub CLI is already installed
$ghInstalled = $null
try {
    $ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
} catch {
    # Command not found, which is expected if gh is not installed
}

if ($null -ne $ghInstalled) {
    Write-Host "GitHub CLI is already installed."
} else {
    Write-Host "Installing GitHub CLI using winget..."
    winget install --id GitHub.cli
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install GitHub CLI using winget. Please install it manually from: https://cli.github.com/"
        exit 1
    }
    
    Write-Host "GitHub CLI installed successfully."
}

Write-Host "`nPlease restart your PowerShell session and run the 'github-auth.ps1' script to authenticate with GitHub."
