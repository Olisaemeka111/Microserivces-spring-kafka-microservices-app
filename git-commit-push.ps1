# Script to add Git to PATH, commit changes, and push to GitHub
# This script addresses the Git PATH issues and commits the API Gateway fixes

# Find Git installation
$gitPaths = @(
    "C:\Program Files\Git\cmd",
    "C:\Program Files (x86)\Git\cmd",
    "${env:ProgramFiles}\Git\cmd",
    "${env:ProgramFiles(x86)}\Git\cmd",
    "${env:LOCALAPPDATA}\Programs\Git\cmd"
)

$gitPath = $null
foreach ($path in $gitPaths) {
    if (Test-Path "$path\git.exe") {
        $gitPath = $path
        break
    }
}

if ($null -eq $gitPath) {
    Write-Host "Git installation not found in common locations. Please specify the path to your Git installation."
    exit 1
}

# Add Git to PATH for this session
$env:Path = "$gitPath;$env:Path"
Write-Host "Added Git to PATH: $gitPath"

# Verify Git is now accessible
try {
    $gitVersion = git --version
    Write-Host "Git is now accessible: $gitVersion"
} catch {
    Write-Host "Failed to access Git. Please use GitHub Desktop instead."
    exit 1
}

# Set Git user information if needed
# Uncomment and modify these lines if needed
# git config --global user.name "Your Name"
# git config --global user.email "your.email@example.com"

# Add all changes
Write-Host "Adding changes..."
git add .

# Create commit
$commitMessage = @"
Fix API Gateway deployment issues

- Added circuit breaker configuration
- Added CORS configuration
- Added health check components
- Added Kubernetes-specific configuration
- Fixed Dockerfile and pipeline issues
- Added cleanup steps to pipeline
- Updated ConfigMap with proper configuration
- Added init container to wait for discovery-server
"@

Write-Host "Committing changes..."
git commit -m "$commitMessage"

# Push changes
Write-Host "Pushing changes to GitHub..."
Write-Host "Note: If you encounter authentication issues, please use GitHub Desktop to push these changes."
git push origin main

Write-Host "Done. If the push failed due to authentication issues, please open GitHub Desktop and push the committed changes from there."
