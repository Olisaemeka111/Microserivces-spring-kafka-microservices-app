# Comprehensive script to fix Git configuration and push to GitHub
Write-Host "Fixing Git configuration and pushing to GitHub..."

# Step 1: Check and fix the Git configuration file directly
Write-Host "`n[1] Checking and fixing Git configuration file..."
$gitConfigPath = Join-Path -Path (Get-Location) -ChildPath ".git\config"
$gitConfig = Get-Content -Path $gitConfigPath -Raw

# Replace placeholder URLs with the correct URL
$correctedConfig = $gitConfig -replace "https://github.com/YOUR-USERNAME/YOUR-REPOSITORY-NAME.git", "https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
$correctedConfig = $correctedConfig -replace "https://github.com/Olisaemeka111/spring-kafka-microservices.git", "https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"

# Write the corrected config back to the file
Set-Content -Path $gitConfigPath -Value $correctedConfig
Write-Host "Git config file updated."

# Step 2: Remove and re-add the remote using Git commands
Write-Host "`n[2] Removing and re-adding the remote..."
git remote remove origin
git remote add origin https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git

# Step 3: Verify the remote configuration
Write-Host "`n[3] Verifying remote configuration..."
$remoteUrl = git config --get remote.origin.url
Write-Host "Remote URL is now: $remoteUrl"

# Step 4: Add all changes
Write-Host "`n[4] Adding all changes..."
git add -A

# Step 5: Commit changes
Write-Host "`n[5] Committing changes..."
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "Update repository configuration and README - $timestamp"
git commit -m $commitMessage

# Step 6: Push to GitHub
Write-Host "`n[6] Pushing to GitHub..."
Write-Host "You may be prompted for your GitHub credentials."
git push -u origin main

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully!"
} else {
    Write-Host "`n❌ ERROR: Failed to push code to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nTrying alternative approach with embedded credentials..."
    $githubUsername = Read-Host "Enter your GitHub username"
    $githubToken = Read-Host "Enter your GitHub personal access token" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken)
    $plainToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # Set the remote URL with embedded credentials
    $repoUrl = "https://$githubUsername`:$plainToken@github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
    git remote set-url origin $repoUrl
    
    # Try pushing again
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully with token authentication!"
    } else {
        Write-Host "`n❌ ERROR: All push attempts failed."
        Write-Host "Please use GitHub Desktop as a reliable alternative."
    }
    
    # Reset the remote URL to remove credentials
    git remote set-url origin "https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git"
}
