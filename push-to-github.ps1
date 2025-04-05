# Script to push code to GitHub
Write-Host "Starting GitHub push process..."

# Add all changes
Write-Host "Adding all changes..."
git add -A

# Commit changes
Write-Host "Committing changes..."
git commit -m "Update microservices configuration for GKE deployment"

# Push to GitHub
Write-Host "Pushing to GitHub..."
git push -u origin main

Write-Host "Push process completed."
