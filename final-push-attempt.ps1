# Final attempt to push to GitHub
Write-Host "Final GitHub Push Attempt"
Write-Host "======================="

# Check if we have any changes to commit
Write-Host "`n[1] Checking for changes..."
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    # Create a test file to ensure we have something to commit
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $testFilePath = "github-push-test-$timestamp.txt"
    "This is a test file created at $timestamp to verify GitHub push functionality." | Out-File -FilePath $testFilePath
    Write-Host "Created test file: $testFilePath"
    git add $testFilePath
}

# Commit changes if needed
$status = git status --porcelain
if (-not [string]::IsNullOrEmpty($status)) {
    Write-Host "`n[2] Committing changes..."
    git commit -m "Test commit for GitHub push - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Try direct push with GitHub CLI if available
Write-Host "`n[3] Attempting push with GitHub CLI if available..."
$ghInstalled = $null
try {
    $ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
} catch {
    # Command not found, which is expected if gh is not installed
}

if ($null -ne $ghInstalled) {
    Write-Host "GitHub CLI found. Attempting authentication and push..."
    gh auth login
    gh repo sync
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully using GitHub CLI!"
        exit 0
    } else {
        Write-Host "GitHub CLI push failed. Trying alternative methods..."
    }
}

# Try push with credential helper
Write-Host "`n[4] Attempting push with credential helper..."
git config --global credential.helper store
git push origin main

# Final recommendation
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS: Code pushed to GitHub successfully!"
} else {
    Write-Host "`n❌ ERROR: All push attempts failed."
    Write-Host "`nRecommendation: Please install and use GitHub Desktop:"
    Write-Host "1. Download from: https://desktop.github.com/"
    Write-Host "2. Install and sign in with your GitHub account"
    Write-Host "3. Add your existing repository: File > Add local repository"
    Write-Host "4. Browse to: c:\Users\olisa\OneDrive\Desktop\Microserivces\spring-kafka-microservices-app"
    Write-Host "5. Commit and push your changes through the GitHub Desktop interface"
}
