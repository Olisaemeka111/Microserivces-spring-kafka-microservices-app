# PowerShell deployment script for GKE Autopilot

# Function to write colored output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "=== Spring Kafka Microservices GKE Deployment Helper ==="
Write-Output "This script will guide you through deployment to GKE Autopilot"
Write-Output ""

# Check for gcloud installation
Write-ColorOutput Yellow "Checking for gcloud installation..."
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Red "gcloud is not installed or not in PATH."
    Write-Output "Please install Google Cloud SDK from: https://cloud.google.com/sdk/docs/install"
    exit 1
}

# Install and configure GKE auth plugin
Write-Host "`nInstalling and configuring GKE auth plugin..." -ForegroundColor Cyan

# Find your Google Cloud SDK installation
$gcloudPath = (Get-Command gcloud).Source
Write-Host "gcloud path: $gcloudPath"

# Install the plugin
gcloud components install gke-gcloud-auth-plugin --quiet

# Set environment variable
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"

# Get the Google Cloud SDK installation path
$sdkPath = Split-Path -Parent (Split-Path -Parent $gcloudPath)
Write-Host "SDK Path: $sdkPath"

# Try different possible locations for the auth plugin
$possibleLocations = @(
    "$sdkPath\bin\gke-gcloud-auth-plugin.exe",
    "$sdkPath\google-cloud-sdk\bin\gke-gcloud-auth-plugin.exe",
    "C:\Users\olisa\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin\gke-gcloud-auth-plugin.exe"
)

$pluginFound = $false
foreach ($location in $possibleLocations) {
    if (Test-Path $location) {
        $pluginExe = $location
        Write-Host "gke-gcloud-auth-plugin found at: $pluginExe" -ForegroundColor Green
        $pluginFound = $true
        break
    }
}

if (-not $pluginFound) {
    # Try to find it using where.exe
    try {
        $whereResult = & where.exe gke-gcloud-auth-plugin 2>$null
        if ($whereResult) {
            $pluginExe = $whereResult[0]
            Write-Host "gke-gcloud-auth-plugin found at: $pluginExe" -ForegroundColor Green
            $pluginFound = $true
        }
    } catch {
        Write-Host "Error finding plugin with where.exe: $_" -ForegroundColor Yellow
    }
}

if (-not $pluginFound) {
    Write-Host "Error: gke-gcloud-auth-plugin.exe could not be found" -ForegroundColor Red
    Write-Host "Please try running: gcloud components install gke-gcloud-auth-plugin" -ForegroundColor Yellow
    exit 1
}

# Test the plugin if found
if ($pluginFound) {
    Write-Host "Testing GKE auth plugin..."
    try {
        $testResult = & $pluginExe --version
        if ($LASTEXITCODE -eq 0) {
            Write-Host "GKE auth plugin test successful" -ForegroundColor Green
        } else {
            Write-Host "Error: GKE auth plugin test failed" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error testing GKE auth plugin: $_" -ForegroundColor Red
        exit 1
    }
}

# Check for kubectl installation
Write-ColorOutput Yellow "Checking for kubectl installation..."
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-ColorOutput Red "kubectl is not installed or not in PATH."
    Write-Output "Please install kubectl using: gcloud components install kubectl"
    exit 1
}

# Get current project
Write-ColorOutput Yellow "Checking current GCP project..."
$PROJECT_ID = $(gcloud config get-value project 2>$null)
if ([string]::IsNullOrEmpty($PROJECT_ID)) {
    Write-ColorOutput Red "No project is currently set."
    Write-Output "Available projects:"
    gcloud projects list
    Write-Output ""
    Write-Output "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
}
else {
    Write-ColorOutput Green "Current project: $PROJECT_ID"
    $PROJECT_NUMBER = $(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
    Write-Output "Project number: $PROJECT_NUMBER"
}

# Check account
Write-ColorOutput Yellow "`nChecking account information..."
$ACCOUNT = $(gcloud config get-value account 2>$null)
if ([string]::IsNullOrEmpty($ACCOUNT)) {
    Write-ColorOutput Red "No account is currently logged in."
    Write-Output "Please run: gcloud auth login"
    exit 1
}
else {
    Write-ColorOutput Green "Currently logged in as: $ACCOUNT"
}

# Check Cloud Build API
Write-ColorOutput Yellow "`nChecking if Cloud Build API is enabled..."
$CLOUDBUILD_ENABLED = $(gcloud services list --enabled --filter="name:cloudbuild.googleapis.com" 2>$null)
if ([string]::IsNullOrEmpty($CLOUDBUILD_ENABLED)) {
    Write-ColorOutput Yellow "Cloud Build API is not enabled. Enabling now..."
    gcloud services enable cloudbuild.googleapis.com
}
else {
    Write-ColorOutput Green "Cloud Build API is enabled"
}

# Check GKE clusters and automatically select the first Autopilot cluster
Write-ColorOutput Yellow "`nLooking for GKE Autopilot clusters..."
$CLUSTERS = $(gcloud container clusters list --filter="autopilot.enabled=true" --format="csv[no-heading](name,location)" 2>$null)
if ([string]::IsNullOrEmpty($CLUSTERS)) {
    Write-ColorOutput Red "No Autopilot clusters found in your project."
    Write-Output "You can create an Autopilot cluster with: gcloud container clusters create-auto YOUR_CLUSTER_NAME --region YOUR_REGION"
    exit 1
}
else {
    # Use the first cluster found (split by comma)
    $CLUSTER_INFO = $CLUSTERS.Split(",")
    $CLUSTER_NAME = $CLUSTER_INFO[0]
    $CLUSTER_REGION = $CLUSTER_INFO[1]
    
    Write-ColorOutput Green "Found Autopilot cluster: $CLUSTER_NAME in region: $CLUSTER_REGION"
    Write-Output "Will use this cluster for deployment."
}

# Configure kubectl
Write-ColorOutput Yellow "`nConfiguring kubectl..."
gcloud config set container/use_client_certificate False

# Connect to cluster
Write-ColorOutput Yellow "`nConnecting to cluster..."
gcloud container clusters get-credentials $CLUSTER_NAME --region $CLUSTER_REGION

# Test kubectl connection
Write-ColorOutput Yellow "`nTesting kubectl connection..."
try {
    $nodes = kubectl get nodes
    Write-ColorOutput Green "Successfully connected to cluster. Nodes:"
    Write-Output $nodes
}
catch {
    Write-ColorOutput Red "Error connecting to cluster: $_"
    Write-ColorOutput Yellow "Please make sure gke-gcloud-auth-plugin is correctly installed and in your PATH"
    exit 1
}

# Create namespace
Write-ColorOutput Yellow "`nCreating namespace if it doesn't exist..."
try {
    kubectl apply -f k8s/namespace.yaml
    Write-ColorOutput Green "Namespace created or already exists"
}
catch {
    Write-ColorOutput Red "Error creating namespace: $_"
    exit 1
}

# Deploy using Cloud Build
Write-ColorOutput Yellow "`nRunning Cloud Build deployment..."
Write-Output "This will build and deploy all microservices to GKE Autopilot."

try {
    gcloud builds submit --config=cloudbuild.yaml --substitutions=_ZONE=$CLUSTER_REGION,_CLUSTER_NAME=$CLUSTER_NAME .
}
catch {
    Write-ColorOutput Red "Error submitting build: $_"
    exit 1
}

# Check deployment status
Write-ColorOutput Yellow "`nChecking deployment status..."
kubectl get deployments -n microservices-app
kubectl get services -n microservices-app

Write-ColorOutput Green "`nDeployment process completed!"
Write-Output "Use 'kubectl get pods -n microservices-app' to monitor pod status"
Write-Output "Use 'kubectl logs -n microservices-app POD_NAME' to check pod logs"

# Monitor deployment
Write-ColorOutput Yellow "`nMonitoring deployment (press Ctrl+C to stop)..."
while ($true) {
    Clear-Host
    Write-ColorOutput Green "=== Deployment Status ==="
    Write-Output ""
    Write-ColorOutput Yellow "Pods:"
    kubectl get pods -n microservices-app
    Write-Output ""
    Write-ColorOutput Yellow "Services:"
    kubectl get services -n microservices-app
    Write-Output ""
    Write-ColorOutput Yellow "Recent Events:"
    kubectl get events -n microservices-app --sort-by='.lastTimestamp' | Select-Object -Last 10
    Start-Sleep -Seconds 5
} 