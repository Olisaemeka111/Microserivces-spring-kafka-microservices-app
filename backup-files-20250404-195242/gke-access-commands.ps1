# PowerShell script to set up GKE access

# Set the environment variable for GKE auth plugin
$env:USE_GKE_GCLOUD_AUTH_PLUGIN = "True"

# Get credentials for your GKE cluster
gcloud container clusters get-credentials spring-kafka-cluster --zone us-central1 --project spring-kafka-microservices

# Check if you can access the cluster
Write-Host "Checking cluster access..." -ForegroundColor Green
kubectl get nodes

# Check if the microservices-app namespace exists
Write-Host "Checking for microservices-app namespace..." -ForegroundColor Green
$namespaceExists = kubectl get namespace microservices-app 2>$null
if (-not $namespaceExists) {
    Write-Host "Creating microservices-app namespace..." -ForegroundColor Yellow
    kubectl create namespace microservices-app
}

# Check for existing deployments
Write-Host "Checking for existing deployments in microservices-app namespace..." -ForegroundColor Green
kubectl get deployments -n microservices-app

# Output instructions for port forwarding
Write-Host "`nOnce deployments are running, use these commands to access services:" -ForegroundColor Cyan
Write-Host "# Access Grafana dashboard" -ForegroundColor Magenta
Write-Host "kubectl port-forward svc/grafana 3000:80 -n microservices-app" -ForegroundColor White
Write-Host "# Then open: http://localhost:3000 (username: admin, password: admin123)" -ForegroundColor White
Write-Host "`n# Access Kibana dashboard" -ForegroundColor Magenta
Write-Host "kubectl port-forward svc/kibana 5601:80 -n microservices-app" -ForegroundColor White
Write-Host "# Then open: http://localhost:5601" -ForegroundColor White
Write-Host "`n# Access API Gateway" -ForegroundColor Magenta
Write-Host "kubectl port-forward svc/api-gateway 8080:80 -n microservices-app" -ForegroundColor White
Write-Host "# Then open: http://localhost:8080" -ForegroundColor White
