# Script to set up Git credentials and push to GitHub
Write-Host "Setting up Git credentials and pushing to GitHub..."

# Configure Git credential manager
Write-Host "Configuring Git credential manager..."
git config --global credential.helper manager

# Set user information if not already set
$userName = git config --global user.name
if ([string]::IsNullOrEmpty($userName)) {
    $inputName = Read-Host "Enter your Git username"
    git config --global user.name "$inputName"
    Write-Host "Git username set to: $inputName"
} else {
    Write-Host "Git username already set to: $userName"
}

$userEmail = git config --global user.email
if ([string]::IsNullOrEmpty($userEmail)) {
    $inputEmail = Read-Host "Enter your Git email"
    git config --global user.email "$inputEmail"
    Write-Host "Git email set to: $inputEmail"
} else {
    Write-Host "Git email already set to: $userEmail"
}

# Verify remote repository
Write-Host "`nVerifying remote repository..."
$remoteUrl = git config --get remote.origin.url
if ([string]::IsNullOrEmpty($remoteUrl)) {
    Write-Host "No remote repository configured. Setting up remote..."
    git remote add origin https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git
    Write-Host "Remote 'origin' added."
} else {
    Write-Host "Remote repository already configured: $remoteUrl"
}

# Add all changes
Write-Host "`nAdding all changes..."
git add -A

# Check if there are changes to commit
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "No changes to commit."
} else {
    # Commit changes
    Write-Host "Committing changes..."
    $commitMessage = "Update microservices configuration for GKE deployment - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $commitMessage
}

# Push to GitHub
Write-Host "`nPushing to GitHub..."
Write-Host "You may be prompted for your GitHub username and password/token in a popup window."
Write-Host "If using a token, enter your token as the password."

git push -u origin main

# Check if push was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPush process completed successfully."
} else {
    Write-Host "`nPush process failed with exit code: $LASTEXITCODE"
    
    # Provide additional guidance
    Write-Host "`nIf you're still having issues, try these steps:"
    Write-Host "1. Create a Personal Access Token (PAT) in GitHub:"
    Write-Host "   - Go to GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)"
    Write-Host "   - Generate a new token with 'repo' permissions"
    Write-Host "   - Copy the token when it's displayed"
    Write-Host "2. Use the token as your password when prompted"
    Write-Host "3. Alternatively, you can use the GitHub CLI or GitHub Desktop application"
}
