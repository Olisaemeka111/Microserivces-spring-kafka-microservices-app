# Script to push code to GitHub main branch
Write-Host "Pushing code to GitHub main branch..."

# Add all changes
Write-Host "`n[1] Adding all changes..."
git add -A

# Commit changes
Write-Host "`n[2] Committing changes..."
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "Update GKE deployment configuration - $timestamp"
git commit -m $commitMessage

# Make sure we're on the main branch
Write-Host "`n[3] Ensuring we're on the main branch..."
git checkout main

# Push to GitHub
Write-Host "`n[4] Pushing to GitHub main branch..."
Write-Host "You may be prompted for your GitHub credentials."
git push -u origin main

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to GitHub main branch successfully!"
    Write-Host "Check your GitHub Actions tab to see if the workflow was triggered."
} else {
    Write-Host "`n❌ ERROR: Failed to push code to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nAlternative approach: Use GitHub Desktop"
    Write-Host "1. Download and install GitHub Desktop from: https://desktop.github.com/"
    Write-Host "2. Open GitHub Desktop and sign in with your GitHub account"
    Write-Host "3. Add your existing repository (File > Add local repository)"
    Write-Host "4. Navigate to: c:\Users\olisa\OneDrive\Desktop\Microserivces\spring-kafka-microservices-app"
    Write-Host "5. Commit any changes and push to GitHub"
}
