# Script to push to GitHub using a personal access token
Write-Host "GitHub Push with Personal Access Token"
Write-Host "===================================="

# Prompt for GitHub token
Write-Host "`n[1] Enter your GitHub personal access token"
Write-Host "   (Create one at GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic))"
Write-Host "   Make sure to give it 'repo' permissions"
$token = Read-Host "Enter your GitHub personal access token" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
$plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Set the remote URL with embedded credentials
Write-Host "`n[2] Setting up remote repository with token..."
$repoUrl = "https://Olisaemeka111:$plainToken@github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
git remote set-url origin $repoUrl
Write-Host "Remote URL updated with token."

# Push to GitHub
Write-Host "`n[3] Pushing to GitHub..."
git push -u origin main

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully!"
} else {
    Write-Host "`n❌ ERROR: Failed to push code to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nAdditional troubleshooting steps:"
    Write-Host "1. Check that your token has 'repo' permissions"
    Write-Host "2. Verify you have proper access to the repository"
    Write-Host "3. Try using GitHub Desktop as an alternative: https://desktop.github.com/"
}

# Reset the remote URL to remove credentials for security
Write-Host "`n[4] Resetting remote URL to remove credentials..."
git remote set-url origin "https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
Write-Host "Remote URL reset for security."
