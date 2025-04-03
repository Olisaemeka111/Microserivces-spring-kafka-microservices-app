# Deploying Spring Kafka Microservices to GKE Autopilot

This guide outlines the steps to deploy this microservices application to Google Kubernetes Engine (GKE) Autopilot using Google Cloud Build for online image building.

## Prerequisites

1. Google Cloud account with billing enabled
2. Existing GKE Autopilot cluster
3. Google Cloud CLI (`gcloud`) installed or use Cloud Shell
4. Git repository with the project code

## Setup Steps

### 1. Connect to Your Existing GKE Autopilot Cluster

```bash
# Set default project
gcloud config set project YOUR_PROJECT_ID

# Get credentials for your existing cluster
gcloud container clusters get-credentials YOUR_CLUSTER_NAME --region YOUR_REGION --project YOUR_PROJECT_ID
```

### 2. Configure Google Cloud Build

```bash
# Enable required APIs
gcloud services enable cloudbuild.googleapis.com

# Grant Cloud Build service account permissions to deploy to GKE
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${CLOUD_BUILD_SERVICE_ACCOUNT}" \
  --role="roles/container.developer"
```

### 3. Create a Cloud Build Trigger

You can create a trigger in the Google Cloud Console:

1. Go to Cloud Build > Triggers
2. Click "Create Trigger"
3. Connect your repository
4. Configure the trigger:
   - Name: `microservices-build`
   - Event: `Push to a branch`
   - Source: Your repository and branch
   - Configuration: `cloudbuild.yaml`
   - Substitution variables:
     - `_ZONE`: `YOUR_CLUSTER_REGION`
     - `_CLUSTER_NAME`: `YOUR_CLUSTER_NAME`

### 4. Deploy the Application

The deployment can be triggered either manually or automatically on git push:

```bash
# Manual trigger
gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_ZONE=YOUR_CLUSTER_REGION,_CLUSTER_NAME=YOUR_CLUSTER_NAME .
```

### 5. Verify Deployment

```bash
# Get the external IP of the API Gateway
kubectl get service api-gateway -n microservices-app

# Access the application at http://EXTERNAL_IP:8080
```

## Notes for GKE Autopilot

- GKE Autopilot requires resource requests and limits for all pods
- The Kubernetes manifests have been updated with appropriate resource specifications
- Autopilot automatically manages node provisioning and scaling based on resource requests
- Storage requirements in Autopilot must use Persistent Volumes rather than local storage

## Troubleshooting

1. Check Cloud Build logs for build issues
2. Check pod status: `kubectl get pods -n microservices-app`
3. Check pod logs: `kubectl logs <pod-name> -n microservices-app`
4. Check Autopilot-specific issues: `kubectl describe pod <pod-name> -n microservices-app` 