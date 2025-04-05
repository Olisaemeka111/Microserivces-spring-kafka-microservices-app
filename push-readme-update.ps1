# Script to push README.md update to GitHub
Write-Host "Pushing README.md update to GitHub..."

# Add only the README.md file
Write-Host "`n[1] Adding README.md file..."
git add README.md

# Commit changes
Write-Host "`n[2] Committing README.md changes..."
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "Update README.md with GKE deployment information - $timestamp"
git commit -m $commitMessage

# Push to GitHub
Write-Host "`n[3] Pushing to GitHub..."
Write-Host "You may be prompted for your GitHub credentials."
git push origin main

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: README.md update pushed to GitHub successfully!"
} else {
    Write-Host "`n❌ ERROR: Failed to push README.md update to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nAlternative approach: Use GitHub Desktop"
    Write-Host "1. Open GitHub Desktop"
    Write-Host "2. You should see the README.md changes in the changes list"
    Write-Host "3. Add a commit message: 'Update README.md with GKE deployment information'"
    Write-Host "4. Click 'Commit to main'"
    Write-Host "5. Click 'Push origin' to push your changes to GitHub"
}
