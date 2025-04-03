#!/bin/bash
set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GCP Authentication and GKE Autopilot Configuration Helper ===${NC}"
echo "This script will help gather necessary information for deploying to GKE Autopilot"
echo

# Get current project details
echo -e "${YELLOW}Checking current GCP project...${NC}"
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
  echo -e "${RED}No project is currently set.${NC}"
  echo "Available projects:"
  gcloud projects list
  echo
  echo -e "Please run: ${YELLOW}gcloud config set project YOUR_PROJECT_ID${NC}"
  exit 1
else
  echo -e "${GREEN}Current project: $PROJECT_ID${NC}"
  PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
  echo "Project number: $PROJECT_NUMBER"
fi

# Get account details
echo -e "\n${YELLOW}Checking account information...${NC}"
ACCOUNT=$(gcloud config get-value account)
if [ -z "$ACCOUNT" ]; then
  echo -e "${RED}No account is currently logged in.${NC}"
  echo -e "Please run: ${YELLOW}gcloud auth login${NC}"
  exit 1
else
  echo -e "${GREEN}Currently logged in as: $ACCOUNT${NC}"
fi

# Check permissions
echo -e "\n${YELLOW}Checking your IAM permissions...${NC}"
echo "This may take a moment..."
PERMISSIONS=$(gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$ACCOUNT" 2>/dev/null || echo "ERROR")

if [ "$PERMISSIONS" == "ERROR" ]; then
  echo -e "${RED}Unable to get permissions. You may not have the necessary access.${NC}"
else
  echo -e "${GREEN}Your IAM roles:${NC}"
  echo "$PERMISSIONS"
  
  # Check for specific container roles
  if echo "$PERMISSIONS" | grep -q "roles/container.admin"; then
    echo -e "${GREEN}✓ You have container admin access. This is sufficient.${NC}"
  elif echo "$PERMISSIONS" | grep -q "roles/container.developer"; then
    echo -e "${GREEN}✓ You have container developer access. This is sufficient.${NC}"
  elif echo "$PERMISSIONS" | grep -q "roles/container.viewer"; then
    echo -e "${YELLOW}⚠ You only have container viewer access. You may not be able to deploy.${NC}"
    echo -e "Recommended: Ask an admin to run: ${YELLOW}gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:$ACCOUNT --role=roles/container.developer${NC}"
  else
    echo -e "${RED}✗ You don't appear to have any container-related roles.${NC}"
    echo -e "Recommended: Ask an admin to run: ${YELLOW}gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:$ACCOUNT --role=roles/container.developer${NC}"
  fi
fi

# Check for GKE clusters
echo -e "\n${YELLOW}Looking for GKE Autopilot clusters...${NC}"
CLUSTERS=$(gcloud container clusters list --filter="autopilot.enabled=true" 2>/dev/null || echo "ERROR")

if [ "$CLUSTERS" == "ERROR" ]; then
  echo -e "${RED}Unable to list clusters. You may not have the necessary access.${NC}"
else
  if echo "$CLUSTERS" | grep -q "NAME"; then
    echo -e "${GREEN}Found the following Autopilot clusters:${NC}"
    echo "$CLUSTERS"
    
    # Extract cluster names and regions
    echo -e "\n${YELLOW}Available clusters for deployment:${NC}"
    CLUSTER_INFO=$(echo "$CLUSTERS" | grep -v "^$" | awk 'NR>1 {print $1 " (Region: " $2 ")"}')
    echo "$CLUSTER_INFO"
    
    # Generate commands
    echo -e "\n${GREEN}=== Deployment Commands ===${NC}"
    echo "To deploy to a specific cluster, run:"
    echo "$CLUSTERS" | grep -v "^$" | awk 'NR>1 {print "\033[1;33mgcloud builds submit --config=cloudbuild.yaml \\\n  --substitutions=_ZONE='$2',_CLUSTER_NAME='$1' .\033[0m"}'
  else
    echo -e "${RED}No Autopilot clusters found in your project.${NC}"
    echo -e "You can create an Autopilot cluster with: ${YELLOW}gcloud container clusters create-auto YOUR_CLUSTER_NAME --region YOUR_REGION${NC}"
  fi
fi

# Check Cloud Build API status
echo -e "\n${YELLOW}Checking if Cloud Build API is enabled...${NC}"
if gcloud services list --enabled | grep -q "cloudbuild.googleapis.com"; then
  echo -e "${GREEN}✓ Cloud Build API is enabled${NC}"
else
  echo -e "${RED}✗ Cloud Build API is not enabled${NC}"
  echo -e "To enable it, run: ${YELLOW}gcloud services enable cloudbuild.googleapis.com${NC}"
fi

# Cloud Build service account
echo -e "\n${YELLOW}Checking Cloud Build service account permissions...${NC}"
CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
echo "Cloud Build service account: $CLOUD_BUILD_SA"

CB_PERMISSIONS=$(gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:serviceAccount:$CLOUD_BUILD_SA" 2>/dev/null || echo "ERROR")

if [ "$CB_PERMISSIONS" == "ERROR" ]; then
  echo -e "${RED}Unable to get Cloud Build permissions.${NC}"
else
  if echo "$CB_PERMISSIONS" | grep -q "roles/container.developer"; then
    echo -e "${GREEN}✓ Cloud Build has container developer permissions${NC}"
  else
    echo -e "${RED}✗ Cloud Build doesn't have container developer permissions${NC}"
    echo -e "To grant permissions, run: ${YELLOW}gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$CLOUD_BUILD_SA --role=roles/container.developer${NC}"
  fi
fi

echo -e "\n${GREEN}=== Summary ===${NC}"
echo "1. Project ID: $PROJECT_ID"
echo "2. Logged in as: $ACCOUNT"
echo "3. Next steps:"
echo "   - Ensure you have proper IAM permissions"
echo "   - Enable Cloud Build API if not already enabled"
echo "   - Grant container.developer role to Cloud Build service account"
echo "   - Connect to your cluster and deploy using the commands above"

# Provide a final, copy-pastable command set
echo -e "\n${GREEN}=== Quick Setup Commands ===${NC}"
echo -e "${YELLOW}# Enable Cloud Build API${NC}"
echo "gcloud services enable cloudbuild.googleapis.com"
echo
echo -e "${YELLOW}# Grant Cloud Build service account permissions${NC}"
echo "gcloud projects add-iam-policy-binding $PROJECT_ID \\"
echo "  --member=\"serviceAccount:$CLOUD_BUILD_SA\" \\"
echo "  --role=\"roles/container.developer\"" 