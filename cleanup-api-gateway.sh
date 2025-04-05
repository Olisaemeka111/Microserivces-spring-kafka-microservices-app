#!/bin/bash

# Cleanup script for API Gateway deployment issues
# This script should be run in Google Cloud Shell to fix the API Gateway deployment

# Set namespace
NAMESPACE="microservices-app"

echo "Starting API Gateway cleanup and redeployment..."

# Delete all existing API Gateway deployments
echo "Deleting existing API Gateway deployments..."
kubectl delete deployment api-gateway -n $NAMESPACE --ignore-not-found=true

# Delete the ConfigMap
echo "Deleting existing API Gateway ConfigMap..."
kubectl delete configmap api-gateway-config -n $NAMESPACE --ignore-not-found=true

# Wait for resources to be fully deleted
echo "Waiting for resources to be fully deleted..."
sleep 10

# Apply the updated ConfigMap
echo "Applying updated API Gateway ConfigMap..."
kubectl apply -f k8s/api-gateway-config.yaml

# Check if discovery-server is running
echo "Checking if discovery-server is running..."
DISCOVERY_SERVER_RUNNING=$(kubectl get pods -n $NAMESPACE -l app=discovery-server -o jsonpath='{.items[0].status.phase}')

if [ "$DISCOVERY_SERVER_RUNNING" != "Running" ]; then
  echo "WARNING: Discovery server is not running. API Gateway deployment may fail."
  echo "Consider deploying discovery-server first with: kubectl apply -f k8s/discovery-server.yaml"
  
  # Ask for confirmation
  read -p "Do you want to continue with API Gateway deployment anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborting deployment."
    exit 1
  fi
fi

# Apply the updated API Gateway deployment
echo "Applying updated API Gateway deployment..."
kubectl apply -f k8s/api-gateway.yaml

# Wait for deployment to start
echo "Waiting for deployment to start..."
sleep 10

# Check deployment status
echo "Checking deployment status..."
kubectl get pods -n $NAMESPACE -l app=api-gateway

echo "API Gateway cleanup and redeployment completed."
echo "Monitor the pods with: kubectl get pods -n $NAMESPACE -l app=api-gateway -w"
echo "Check logs with: kubectl logs -n $NAMESPACE -l app=api-gateway --tail=100"
