#!/bin/bash

# Script to deploy monitoring and logging for Spring Kafka Microservices

echo "Deploying monitoring and logging components..."

# Create directories if they don't exist
mkdir -p k8s/monitoring
mkdir -p k8s/logging

# Deploy monitoring components
echo "Deploying Prometheus..."
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml

echo "Deploying Grafana..."
kubectl apply -f k8s/monitoring/grafana-deployment.yaml

# Deploy logging components
echo "Deploying Elasticsearch..."
kubectl apply -f k8s/logging/elasticsearch-deployment.yaml

echo "Deploying Kibana..."
kubectl apply -f k8s/logging/kibana-deployment.yaml

echo "Deploying Logstash..."
kubectl apply -f k8s/logging/logstash-deployment.yaml

echo "Deploying Filebeat..."
kubectl apply -f k8s/logging/filebeat-deployment.yaml

# Wait for deployments to be ready
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment prometheus -n microservices-app
kubectl rollout status deployment grafana -n microservices-app
kubectl rollout status statefulset elasticsearch -n microservices-app
kubectl rollout status deployment kibana -n microservices-app
kubectl rollout status deployment logstash -n microservices-app

# Get service URLs
echo "Getting service URLs..."
PROMETHEUS_URL=$(kubectl get service prometheus -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
GRAFANA_URL=$(kubectl get service grafana -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
KIBANA_URL=$(kubectl get service kibana -n microservices-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Monitoring and logging deployment complete!"
echo "Access your services at:"
echo "Prometheus: http://${PROMETHEUS_URL}:9090"
echo "Grafana: http://${GRAFANA_URL}"
echo "Kibana: http://${KIBANA_URL}"
echo ""
echo "Grafana default credentials:"
echo "Username: admin"
echo "Password: admin123"
