# PowerShell script to deploy monitoring and logging for Spring Kafka Microservices

Write-Host "Deploying monitoring and logging components..." -ForegroundColor Green

# Deploy monitoring components
Write-Host "Deploying Prometheus..." -ForegroundColor Cyan
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml

Write-Host "Deploying Grafana..." -ForegroundColor Cyan
kubectl apply -f k8s/monitoring/grafana-deployment.yaml

# Deploy logging components
Write-Host "Deploying Elasticsearch..." -ForegroundColor Cyan
kubectl apply -f k8s/logging/elasticsearch-deployment.yaml

Write-Host "Deploying Kibana..." -ForegroundColor Cyan
kubectl apply -f k8s/logging/kibana-deployment.yaml

Write-Host "Deploying Logstash..." -ForegroundColor Cyan
kubectl apply -f k8s/logging/logstash-deployment.yaml

Write-Host "Deploying Filebeat..." -ForegroundColor Cyan
kubectl apply -f k8s/logging/filebeat-deployment.yaml

# Wait for deployments to be ready
Write-Host "Waiting for deployments to be ready..." -ForegroundColor Yellow
kubectl rollout status deployment prometheus -n microservices-app
kubectl rollout status deployment grafana -n microservices-app
kubectl rollout status statefulset elasticsearch -n microservices-app
kubectl rollout status deployment kibana -n microservices-app
kubectl rollout status deployment logstash -n microservices-app

# Get service URLs
Write-Host "Getting service URLs..." -ForegroundColor Yellow
$PROMETHEUS_URL = kubectl get service prometheus -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
$GRAFANA_URL = kubectl get service grafana -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
$KIBANA_URL = kubectl get service kibana -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

Write-Host "Monitoring and logging deployment complete!" -ForegroundColor Green
Write-Host "Access your services at:" -ForegroundColor Green
Write-Host "Prometheus: http://${PROMETHEUS_URL}:9090" -ForegroundColor Magenta
Write-Host "Grafana: http://${GRAFANA_URL}" -ForegroundColor Magenta
Write-Host "Kibana: http://${KIBANA_URL}" -ForegroundColor Magenta
Write-Host ""
Write-Host "Grafana default credentials:" -ForegroundColor Yellow
Write-Host "Username: admin" -ForegroundColor Yellow
Write-Host "Password: admin123" -ForegroundColor Yellow
