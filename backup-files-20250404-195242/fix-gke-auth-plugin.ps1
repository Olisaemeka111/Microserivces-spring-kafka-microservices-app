# PowerShell script to fix gke-gcloud-auth-plugin PATH issues

# Find the location of the gke-gcloud-auth-plugin
$gcloudPath = (Get-Command gcloud -ErrorAction SilentlyContinue).Path
if ($gcloudPath) {
    $gcloudDir = Split-Path -Parent $gcloudPath
    $gcloudBaseDir = Split-Path -Parent $gcloudDir
    
    Write-Host "Google Cloud SDK found at: $gcloudBaseDir" -ForegroundColor Green
    
    # Add potential plugin locations to PATH
    $env:PATH += ";$gcloudDir"
    $env:PATH += ";$gcloudBaseDir\bin"
    $env:PATH += ";$gcloudBaseDir\platform\gke-gcloud-auth-plugin"
    $env:PATH += ";$gcloudBaseDir\platform\bundledpythonunix\bin"
    
    # Set the required environment variable
    $env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
    
    Write-Host "PATH updated with potential plugin locations" -ForegroundColor Green
    
    # Try to find the plugin
    $pluginPath = Get-ChildItem -Path $gcloudBaseDir -Recurse -Filter "gke-gcloud-auth-plugin.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    
    if ($pluginPath) {
        Write-Host "Found plugin at: $pluginPath" -ForegroundColor Green
        $pluginDir = Split-Path -Parent $pluginPath
        $env:PATH += ";$pluginDir"
        Write-Host "Added plugin directory to PATH" -ForegroundColor Green
    } else {
        Write-Host "Plugin not found. Trying to reinstall..." -ForegroundColor Yellow
        gcloud components install gke-gcloud-auth-plugin --quiet
    }
} else {
    Write-Host "Google Cloud SDK not found in PATH" -ForegroundColor Red
}

# Display current PATH for debugging
Write-Host "`nCurrent PATH:" -ForegroundColor Cyan
$env:PATH -split ";" | ForEach-Object { Write-Host "  $_" }

Write-Host "`nTrying to get cluster credentials..." -ForegroundColor Cyan
gcloud container clusters get-credentials spring-kafka-cluster --zone us-central1 --project spring-kafka-microservices

Write-Host "`nTrying to access the cluster..." -ForegroundColor Cyan
kubectl get nodes

Write-Host "`nIf you're still having issues, please start your cluster in the Google Cloud Console:" -ForegroundColor Yellow
Write-Host "https://console.cloud.google.com/kubernetes/list" -ForegroundColor Cyan
