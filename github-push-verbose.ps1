# Verbose script to push code to GitHub with error handling
Write-Host "Starting GitHub push process with verbose output..."

# Check Git status
Write-Host "`n[1] Checking Git status..."
git status

# Check remote configuration
Write-Host "`n[2] Checking remote configuration..."
git remote -v

# Check current branch
Write-Host "`n[3] Checking current branch..."
git branch

# Add all changes
Write-Host "`n[4] Adding all changes..."
git add -A
git status

# Commit changes
Write-Host "`n[5] Committing changes..."
git commit -m "Update microservices configuration for GKE deployment"

# Set credentials helper to store credentials
Write-Host "`n[6] Setting credential helper..."
git config --global credential.helper store

# Push to GitHub with verbose output
Write-Host "`n[7] Pushing to GitHub with verbose output..."
git push -v origin main

# Check if push was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nPush process completed successfully."
} else {
    Write-Host "`nPush process failed with exit code: $LASTEXITCODE"
    
    # Try alternative push method if the first one fails
    Write-Host "`n[8] Trying alternative push method..."
    git push https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nAlternative push method succeeded."
    } else {
        Write-Host "`nAlternative push method also failed with exit code: $LASTEXITCODE"
        Write-Host "Please check your GitHub credentials and repository access."
    }
}
