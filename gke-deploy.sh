#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Spring Kafka Microservices GKE Deployment Helper ===${NC}"
echo "This script will guide you through deployment to GKE Autopilot"
echo

# First run the auth helper to get GCP info
echo -e "${YELLOW}Step 1: Checking GCP authentication and permissions${NC}"
./gcp-auth-helper.sh

# Ask if user wants to proceed with deployment
echo
echo -e "${YELLOW}Do you want to proceed with deployment? (y/n)${NC}"
read -p "> " proceed

if [[ $proceed != "y" && $proceed != "Y" ]]; then
  echo "Deployment aborted."
  exit 0
fi

# Prompt for cluster name and region
echo
echo -e "${YELLOW}Enter your GKE Autopilot cluster name:${NC}"
read -p "> " CLUSTER_NAME

echo -e "${YELLOW}Enter the cluster region:${NC}"
read -p "> " CLUSTER_REGION

echo
echo -e "${YELLOW}Step 2: Connecting to cluster and preparing for deployment${NC}"
echo "Connecting to cluster $CLUSTER_NAME in region $CLUSTER_REGION..."
gcloud container clusters get-credentials $CLUSTER_NAME --region $CLUSTER_REGION

# Apply the namespace first
echo
echo -e "${YELLOW}Creating namespace if it doesn't exist...${NC}"
kubectl apply -f k8s/namespace.yaml

# Build and deploy using Cloud Build
echo
echo -e "${YELLOW}Step 3: Running Cloud Build deployment${NC}"
echo "This will build and deploy all microservices to GKE Autopilot."
echo -e "${YELLOW}Building and deploying using Cloud Build...${NC}"
gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_ZONE=$CLUSTER_REGION,_CLUSTER_NAME=$CLUSTER_NAME .

# Run the deployment troubleshooter
echo
echo -e "${YELLOW}Step 4: Checking deployment status${NC}"
./deploy-troubleshoot.sh

echo
echo -e "${GREEN}Deployment process completed!${NC}"
echo "Use the deploy-troubleshoot.sh script to continue monitoring the deployment." 