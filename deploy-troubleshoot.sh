#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GKE Autopilot Deployment Troubleshooter ===${NC}"
echo "This script will help diagnose issues with your microservices deployment"
echo

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo -e "${RED}kubectl is not installed or not in PATH.${NC}"
  echo -e "Please install kubectl or add it to your PATH."
  exit 1
fi

# Get current context
echo -e "${YELLOW}Current kubectl context:${NC}"
CURRENT_CONTEXT=$(kubectl config current-context)
echo -e "${GREEN}$CURRENT_CONTEXT${NC}"

# Check namespace
echo -e "\n${YELLOW}Checking for microservices-app namespace...${NC}"
if kubectl get namespace microservices-app &> /dev/null; then
  echo -e "${GREEN}✓ Namespace microservices-app exists${NC}"
else
  echo -e "${RED}✗ Namespace microservices-app does not exist${NC}"
  echo "Creating namespace..."
  kubectl apply -f k8s/namespace.yaml
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Namespace created successfully${NC}"
  else
    echo -e "${RED}Failed to create namespace. You may not have sufficient permissions.${NC}"
    exit 1
  fi
fi

# Check deployments
echo -e "\n${YELLOW}Checking deployments in microservices-app namespace...${NC}"
DEPLOYMENTS=$(kubectl get deployments -n microservices-app 2>/dev/null || echo "ERROR")

if [ "$DEPLOYMENTS" == "ERROR" ]; then
  echo -e "${RED}Unable to get deployments. You may not have the necessary access.${NC}"
else
  if echo "$DEPLOYMENTS" | grep -q "No resources found"; then
    echo -e "${RED}No deployments found in microservices-app namespace.${NC}"
    echo "Your deployment might not have started or failed completely."
  else
    echo "$DEPLOYMENTS"
    
    # Check for unavailable deployments
    UNAVAILABLE=$(echo "$DEPLOYMENTS" | awk 'NR>1 && $2!=$4 {print $1}')
    if [ -n "$UNAVAILABLE" ]; then
      echo -e "\n${RED}The following deployments are not fully available:${NC}"
      for dep in $UNAVAILABLE; do
        echo -e "${YELLOW}$dep${NC}"
        
        # Check pod status for this deployment
        echo -e "\n${YELLOW}Pods for $dep:${NC}"
        kubectl get pods -n microservices-app -l app=$dep
        
        # Get events for this deployment
        echo -e "\n${YELLOW}Events for $dep:${NC}"
        kubectl describe deployment $dep -n microservices-app | grep -A 20 "Events:"
        
        # Get logs for the first pod of this deployment
        POD=$(kubectl get pods -n microservices-app -l app=$dep -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        if [ -n "$POD" ]; then
          echo -e "\n${YELLOW}Logs for $POD:${NC}"
          kubectl logs -n microservices-app $POD --tail=50 || echo "No logs available yet"
        fi
      done
    else
      echo -e "${GREEN}✓ All deployments are available${NC}"
    fi
  fi
fi

# Check services
echo -e "\n${YELLOW}Checking services in microservices-app namespace...${NC}"
SERVICES=$(kubectl get services -n microservices-app 2>/dev/null || echo "ERROR")

if [ "$SERVICES" == "ERROR" ]; then
  echo -e "${RED}Unable to get services. You may not have the necessary access.${NC}"
else
  echo "$SERVICES"
  
  # Check if the API Gateway has an external IP
  API_GATEWAY_IP=$(echo "$SERVICES" | grep "api-gateway" | awk '{print $4}')
  if [ "$API_GATEWAY_IP" == "<pending>" ]; then
    echo -e "${YELLOW}⚠ API Gateway external IP is still pending${NC}"
  elif [ -n "$API_GATEWAY_IP" ] && [ "$API_GATEWAY_IP" != "<none>" ]; then
    echo -e "${GREEN}✓ API Gateway accessible at: http://$API_GATEWAY_IP:8080${NC}"
  else
    echo -e "${RED}✗ API Gateway service not found or has no external IP${NC}"
  fi
fi

# Check PVCs
echo -e "\n${YELLOW}Checking persistent volume claims...${NC}"
PVCS=$(kubectl get pvc -n microservices-app 2>/dev/null || echo "ERROR")

if [ "$PVCS" == "ERROR" ]; then
  echo -e "${RED}Unable to get PVCs. You may not have the necessary access.${NC}"
else
  echo "$PVCS"
  
  # Check for pending PVCs
  PENDING_PVCS=$(echo "$PVCS" | grep "Pending" | awk '{print $1}')
  if [ -n "$PENDING_PVCS" ]; then
    echo -e "${RED}⚠ The following PVCs are in Pending state:${NC}"
    for pvc in $PENDING_PVCS; do
      echo -e "${YELLOW}$pvc${NC}"
      echo -e "\n${YELLOW}Details for $pvc:${NC}"
      kubectl describe pvc $pvc -n microservices-app
    done
  fi
fi

# Check recently failed pods
echo -e "\n${YELLOW}Checking for recently terminated pods...${NC}"
FAILED_PODS=$(kubectl get pods -n microservices-app --field-selector=status.phase!=Running,status.phase!=Succeeded -o wide 2>/dev/null || echo "ERROR")

if [ "$FAILED_PODS" == "ERROR" ]; then
  echo -e "${RED}Unable to check failed pods.${NC}"
elif [ "$FAILED_PODS" == "No resources found" ] || ! echo "$FAILED_PODS" | grep -q NAME; then
  echo -e "${GREEN}✓ No failed pods found${NC}"
else
  echo "$FAILED_PODS"
  
  # Get events for the namespace
  echo -e "\n${YELLOW}Recent events in the namespace:${NC}"
  kubectl get events -n microservices-app --sort-by='.lastTimestamp' | tail -n 20
fi

echo -e "\n${GREEN}=== Summary of Actions to Take ===${NC}"
echo "1. If deployments are failing:"
echo "   - Check pod logs for application errors"
echo "   - Verify your Kubernetes manifests have proper resource limits"
echo "   - Ensure Cloud Build service account has proper permissions"
echo
echo "2. If PVCs are pending:"
echo "   - Verify storage class 'standard' exists in your cluster"
echo "   - Check quota limits for your Autopilot cluster"
echo
echo "3. If services have no external IP:"
echo "   - Autopilot loadbalancer provisioning can take a few minutes"
echo "   - Verify network settings in your GCP project"
echo
echo "4. For application-specific issues:"
echo "   - Check the logs of individual microservices"
echo "   - Verify connectivity between services (Kafka, MongoDB, MySQL)"

echo -e "\n${GREEN}=== Quick Debug Commands ===${NC}"
echo -e "${YELLOW}# Get detailed logs for a specific pod${NC}"
echo "kubectl logs -n microservices-app POD_NAME"
echo
echo -e "${YELLOW}# Describe a specific deployment${NC}"
echo "kubectl describe deployment DEPLOYMENT_NAME -n microservices-app"
echo
echo -e "${YELLOW}# Connect to a service pod for troubleshooting${NC}"
echo "kubectl exec -it -n microservices-app POD_NAME -- bash" 