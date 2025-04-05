# Script to set up a new GitHub repository and push your code
Write-Host "Setting up a new GitHub repository and pushing your code..."

# Step 1: Rename the current remote to backup
Write-Host "`n[1] Renaming current remote to 'backup'..."
git remote rename origin backup

# Step 2: Create a new repository on GitHub
Write-Host "`n[2] Instructions to create a new repository on GitHub:"
Write-Host "   a. Go to https://github.com/new"
Write-Host "   b. Name your repository (e.g., 'spring-kafka-microservices')"
Write-Host "   c. Make it Public or Private as desired"
Write-Host "   d. Do NOT initialize with README, .gitignore, or license"
Write-Host "   e. Click 'Create repository'"
Write-Host "   f. Copy the repository URL (e.g., https://github.com/YourUsername/spring-kafka-microservices.git)"
Write-Host "`n   After creating the repository, press Enter to continue..."
$null = Read-Host

# Step 3: Add the new remote
Write-Host "`n[3] Adding new remote repository..."
$newRepoUrl = Read-Host "Enter the URL of your new GitHub repository"
git remote add origin $newRepoUrl
Write-Host "New remote 'origin' added: $newRepoUrl"

# Step 4: Push all branches and tags to the new repository
Write-Host "`n[4] Pushing all branches and tags to the new repository..."
Write-Host "   This may take some time depending on the size of your repository."
git push -u origin --all
git push -u origin --tags

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to new GitHub repository successfully!"
    Write-Host "Check your GitHub repository to see your code."
} else {
    Write-Host "`n❌ ERROR: Failed to push code to GitHub. Exit code: $LASTEXITCODE"
    
    Write-Host "`nAlternative approach: Use GitHub Desktop with the new repository"
    Write-Host "1. In GitHub Desktop, go to File > Add local repository"
    Write-Host "2. Browse to: c:\Users\olisa\OneDrive\Desktop\Microserivces\spring-kafka-microservices-app"
    Write-Host "3. When prompted about the repository not being found, choose to publish this repository"
    Write-Host "4. Select your GitHub account and enter the new repository name"
    Write-Host "5. Click 'Publish Repository'"
}
