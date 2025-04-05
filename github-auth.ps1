# Script to authenticate with GitHub and push code
Write-Host "GitHub Authentication and Push Script"
Write-Host "====================================="

# 1. Configure Git user information
Write-Host "`n[1] Setting up Git user information..."
$gitUserName = Read-Host "Enter your GitHub username"
$gitEmail = Read-Host "Enter your GitHub email"

git config --global user.name "$gitUserName"
git config --global user.email "$gitEmail"
Write-Host "Git user information configured."

# 2. Set up credential manager
Write-Host "`n[2] Setting up Git credential manager..."
git config --global credential.helper manager-core

# 3. Set up the remote repository
Write-Host "`n[3] Setting up remote repository..."
git remote remove origin
git remote add origin https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git
Write-Host "Remote 'origin' configured."

# 4. Create a test file to ensure we have changes to commit
Write-Host "`n[4] Creating a test file to ensure we have changes to commit..."
$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$testFilePath = "push-test-$timestamp.txt"
"This is a test file created at $timestamp to verify GitHub push functionality." | Out-File -FilePath $testFilePath
Write-Host "Test file created: $testFilePath"

# 5. Add and commit changes
Write-Host "`n[5] Adding and committing changes..."
git add .
git commit -m "Test commit for GitHub push verification - $timestamp"

# 6. Push to GitHub with credential prompt
Write-Host "`n[6] Pushing to GitHub..."
Write-Host "You will be prompted for your GitHub password or personal access token."
Write-Host "IMPORTANT: If you use two-factor authentication, you MUST use a personal access token instead of your password."
Write-Host "To create a personal access token, go to: GitHub > Settings > Developer settings > Personal access tokens"

git push -u origin main

# 7. Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully!"
} else {
    Write-Host "`n❌ ERROR: Failed to push code to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nTroubleshooting steps:"
    Write-Host "1. Make sure you're using a personal access token (not password) if you have 2FA enabled"
    Write-Host "2. Check that your token has 'repo' permissions"
    Write-Host "3. Verify you have proper access to the repository"
    Write-Host "4. Try using GitHub Desktop as an alternative: https://desktop.github.com/"
}
