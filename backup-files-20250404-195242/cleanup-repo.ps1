# Repository cleanup script
# This script will help clean up untracked files while preserving essential documentation

# Files to keep (essential documentation and scripts)
$filesToKeep = @(
    "access-gke-cluster-steps.txt",      # Main GKE access documentation
    "cloud-shell-commands.txt",          # Essential Cloud Shell commands
    "check-deployment-status.txt",       # Useful for checking deployment status
    "deploy-monitoring-to-github-actions.txt"  # GitHub Actions deployment guide
)

# Create a backup directory for files we're removing
$backupDir = ".\backup-files-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "Created backup directory: $backupDir" -ForegroundColor Green

# Get all untracked files
$untrackedFiles = git ls-files --others --exclude-standard

foreach ($file in $untrackedFiles) {
    $fileName = Split-Path $file -Leaf
    
    # Skip files in the k8s directory - these might be important
    if ($file -like "k8s/*") {
        Write-Host "Skipping k8s file: $file" -ForegroundColor Yellow
        continue
    }
    
    # Check if the file is in our keep list
    if ($filesToKeep -contains $fileName) {
        Write-Host "Keeping essential file: $file" -ForegroundColor Green
        
        # Add it to git so it's tracked
        git add $file
    } else {
        # Move the file to backup instead of deleting
        $destination = Join-Path $backupDir $fileName
        Write-Host "Moving to backup: $file -> $destination" -ForegroundColor Yellow
        Move-Item -Path $file -Destination $destination -Force
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Essential files have been added to git tracking." -ForegroundColor Green
Write-Host "Other files have been moved to: $backupDir" -ForegroundColor Green
Write-Host "You can delete the backup directory if you don't need those files anymore." -ForegroundColor Yellow
Write-Host "`nRun 'git status' to see the current status of your repository." -ForegroundColor Cyan
