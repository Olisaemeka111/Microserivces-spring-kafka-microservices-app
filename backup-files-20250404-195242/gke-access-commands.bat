@echo off
echo Setting up GKE access...

REM Set the environment variable for GKE auth plugin
set USE_GKE_GCLOUD_AUTH_PLUGIN=True

REM Get credentials for your GKE cluster
echo Getting credentials for GKE cluster...
gcloud container clusters get-credentials spring-kafka-cluster --zone us-central1 --project spring-kafka-microservices

REM Check if you can access the cluster
echo Checking cluster access...
kubectl get nodes

REM Check if the microservices-app namespace exists
echo Checking for microservices-app namespace...
kubectl get namespace microservices-app 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Creating microservices-app namespace...
    kubectl create namespace microservices-app
)

REM Check for existing deployments
echo Checking for existing deployments in microservices-app namespace...
kubectl get deployments -n microservices-app

REM Output instructions for port forwarding
echo.
echo Once deployments are running, use these commands to access services:
echo # Access Grafana dashboard
echo kubectl port-forward svc/grafana 3000:80 -n microservices-app
echo # Then open: http://localhost:3000 (username: admin, password: admin123)
echo.
echo # Access Kibana dashboard
echo kubectl port-forward svc/kibana 5601:80 -n microservices-app
echo # Then open: http://localhost:5601
echo.
echo # Access API Gateway
echo kubectl port-forward svc/api-gateway 8080:80 -n microservices-app
echo # Then open: http://localhost:8080

pause
