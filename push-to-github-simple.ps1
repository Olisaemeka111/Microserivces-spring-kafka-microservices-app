# Simple script to push code to GitHub
Write-Host "Starting GitHub push process..."

# Add all changes
Write-Host "Adding all changes..."
git add -A

# Commit changes
Write-Host "Committing changes..."
$commitMessage = "Update microservices configuration for GKE deployment - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

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
