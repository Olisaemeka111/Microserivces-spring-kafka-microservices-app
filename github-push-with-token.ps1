# Script to push to GitHub using a personal access token
Write-Host "This script will help you push to GitHub using a personal access token."
Write-Host "You will need to create a personal access token in your GitHub account settings."
Write-Host "GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)"
Write-Host "Make sure to give it 'repo' permissions."
Write-Host ""

# Prompt for GitHub username and token
$username = Read-Host "Enter your GitHub username"
$token = Read-Host "Enter your GitHub personal access token" -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

# Set the remote URL with credentials embedded
$repoUrl = "https://$username`:$plainToken@github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
Write-Host "Setting remote URL with credentials..."
git remote set-url origin $repoUrl

# Add all changes
Write-Host "Adding all changes..."
git add -A

# Commit changes
Write-Host "Committing changes..."
git commit -m "Update microservices configuration for GKE deployment"

# Push to GitHub
Write-Host "Pushing to GitHub..."
git push -u origin main

# Check if push was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Push process completed successfully."
} else {
    Write-Host "Push process failed with exit code: $LASTEXITCODE"
    Write-Host "Please check your GitHub credentials and repository access."
}

# Reset the remote URL to remove credentials
Write-Host "Resetting remote URL to remove credentials..."
git remote set-url origin "https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
