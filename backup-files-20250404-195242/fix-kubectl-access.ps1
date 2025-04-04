# PowerShell script to fix kubectl access to GKE

# Find Google Cloud SDK installation
$cloudSdkPaths = @(
    "C:\Program Files (x86)\Google\Cloud SDK\google-cloud-sdk",
    "C:\Users\olisa\AppData\Local\Google\Cloud SDK\google-cloud-sdk",
    "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk"
)

$foundSdk = $false
foreach ($path in $cloudSdkPaths) {
    if (Test-Path $path) {
        $cloudSdkPath = $path
        $foundSdk = $true
        Write-Host "Found Google Cloud SDK at: $cloudSdkPath" -ForegroundColor Green
        break
    }
}

if (-not $foundSdk) {
    Write-Host "Google Cloud SDK not found in common locations. Please specify the path manually." -ForegroundColor Red
    exit 1
}

# Find the gke-gcloud-auth-plugin
$pluginPath = Get-ChildItem -Path $cloudSdkPath -Recurse -Filter "gke-gcloud-auth-plugin.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if (-not $pluginPath) {
    Write-Host "gke-gcloud-auth-plugin.exe not found. Trying to install it..." -ForegroundColor Yellow
    & "$cloudSdkPath\bin\gcloud.cmd" components install gke-gcloud-auth-plugin --quiet
    
    # Check again after installation
    $pluginPath = Get-ChildItem -Path $cloudSdkPath -Recurse -Filter "gke-gcloud-auth-plugin.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    
    if (-not $pluginPath) {
        Write-Host "Failed to find gke-gcloud-auth-plugin.exe even after installation attempt." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Found gke-gcloud-auth-plugin at: $pluginPath" -ForegroundColor Green
$pluginDir = Split-Path -Parent $pluginPath

# Add to PATH permanently
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if (-not $currentPath.Contains($pluginDir)) {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$pluginDir", "User")
    Write-Host "Added plugin directory to user PATH permanently" -ForegroundColor Green
}

# Add to current session PATH
$env:PATH += ";$pluginDir"

# Set the required environment variable permanently
[Environment]::SetEnvironmentVariable("USE_GKE_GCLOUD_AUTH_PLUGIN", "True", "User")
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"
Write-Host "Set USE_GKE_GCLOUD_AUTH_PLUGIN environment variable" -ForegroundColor Green

# Add Cloud SDK bin to PATH for current session if needed
$cloudSdkBin = "$cloudSdkPath\bin"
if (-not $env:PATH.Contains($cloudSdkBin)) {
    $env:PATH += ";$cloudSdkBin"
}

Write-Host "`nTrying to get cluster credentials..." -ForegroundColor Cyan
& "$cloudSdkBin\gcloud.cmd" container clusters get-credentials spring-kafka-cluster --zone us-central1 --project spring-kafka-microservices

Write-Host "`nTrying to access the cluster..." -ForegroundColor Cyan
kubectl get nodes

Write-Host "`nIf successful, you can now deploy the monitoring components with:" -ForegroundColor Green
Write-Host "kubectl apply -f k8s/monitoring/prometheus-config.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/monitoring/prometheus-deployment.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/monitoring/grafana-deployment.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/logging/elasticsearch-deployment.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/logging/kibana-deployment.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/logging/logstash-deployment.yaml" -ForegroundColor White
Write-Host "kubectl apply -f k8s/logging/filebeat-deployment.yaml" -ForegroundColor White
