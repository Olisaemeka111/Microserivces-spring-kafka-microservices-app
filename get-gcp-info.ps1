# Script to get GCP information for GitHub Secrets
# Make sure you're logged in to gcloud CLI before running this script

# Get the current project ID
$projectId = gcloud config get-value project

# Get list of GKE clusters
Write-Host "Getting list of GKE clusters..."
$clusters = gcloud container clusters list --format="json" | ConvertFrom-Json

# Create output file
$outputFile = "gcp-github-secrets.txt"
"# GCP GitHub Secrets" | Out-File -FilePath $outputFile
"# Add these secrets to your GitHub repository" | Out-File -FilePath $outputFile -Append
"" | Out-File -FilePath $outputFile -Append

# Add GCP_PROJECT_ID
"GCP_PROJECT_ID: $projectId" | Out-File -FilePath $outputFile -Append
"" | Out-File -FilePath $outputFile -Append

# Add GCP_SA_KEY
"GCP_SA_KEY: [Copy the entire content of your github-actions-key.json file]" | Out-File -FilePath $outputFile -Append
"" | Out-File -FilePath $outputFile -Append

# List available clusters
"Available GKE Clusters:" | Out-File -FilePath $outputFile -Append
foreach ($cluster in $clusters) {
    "- Cluster Name: $($cluster.name)" | Out-File -FilePath $outputFile -Append
    "  Zone: $($cluster.zone)" | Out-File -FilePath $outputFile -Append
    "  Location: $($cluster.location)" | Out-File -FilePath $outputFile -Append
    "" | Out-File -FilePath $outputFile -Append
}

# Example secrets format
"Example GitHub Secrets:" | Out-File -FilePath $outputFile -Append
"GKE_CLUSTER: [cluster name from above]" | Out-File -FilePath $outputFile -Append
"GKE_ZONE: [zone from above]" | Out-File -FilePath $outputFile -Append

Write-Host "GCP information has been saved to $outputFile"
