# Script to fix GitHub remote URL
Write-Host "Fixing GitHub remote URL..."

# Remove the current origin remote
Write-Host "`n[1] Removing current origin remote..."
git remote remove origin

# Add the correct remote URL
Write-Host "`n[2] Adding correct remote URL..."
git remote add origin https://github.com/Olisaemeka111/Microserivces-spring-kafka-microservices-app.git

# Verify the remote URL
Write-Host "`n[3] Verifying remote URL..."
git remote -v

Write-Host "`nRemote URL has been fixed. Now you can try pushing your changes again."
