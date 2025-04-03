# Deploying to GKE Autopilot on Windows

This guide provides instructions for deploying the Spring Kafka microservices application to GKE Autopilot from Windows.

## Prerequisites

1. Google Cloud SDK installed (gcloud)
2. kubectl installed and configured
3. Git Bash or similar Bash shell for Windows

## Setup Instructions

### 1. Install Required Tools

- **Google Cloud SDK**: Download and install from https://cloud.google.com/sdk/docs/install
- **kubectl**: Install using `gcloud components install kubectl`
- **Git Bash**: Download and install from https://git-scm.com/download/win

### 2. Make Scripts Executable in Git Bash

Open Git Bash in your project directory and run:

```bash
cd /c/Users/olisa/OneDrive/Desktop/Microserivces/spring-kafka-microservices-app
chmod +x gcp-auth-helper.sh deploy-troubleshoot.sh gke-deploy.sh
```

### 3. Run the Deployment Helper in Git Bash

```bash
cd /c/Users/olisa/OneDrive/Desktop/Microserivces/spring-kafka-microservices-app
./gke-deploy.sh
```

The script will:
1. Check your GCP authentication and permissions
2. Connect to your GKE Autopilot cluster
3. Build and deploy the application using Cloud Build
4. Check the deployment status and troubleshoot issues

### 4. Alternative: Manual Deployment Steps

If you prefer running commands individually:

1. **Authenticate with GCP**:
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Get cluster credentials**:
   ```bash
   gcloud container clusters get-credentials YOUR_CLUSTER_NAME --region YOUR_REGION
   ```

3. **Enable Cloud Build API**:
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   ```

4. **Grant permissions to Cloud Build service account**:
   ```bash
   PROJECT_ID=$(gcloud config get-value project)
   PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
   CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:$CLOUD_BUILD_SA" \
     --role="roles/container.developer"
   ```

5. **Deploy using Cloud Build**:
   ```bash
   gcloud builds submit --config=cloudbuild.yaml \
     --substitutions=_ZONE=YOUR_REGION,_CLUSTER_NAME=YOUR_CLUSTER_NAME .
   ```

6. **Check deployment status**:
   ```bash
   kubectl get deployments -n microservices-app
   kubectl get services -n microservices-app
   ```

## Troubleshooting

If you encounter issues:

1. Run the troubleshooting script in Git Bash:
   ```bash
   ./deploy-troubleshoot.sh
   ```

2. Check Cloud Build logs:
   ```bash
   gcloud builds list
   gcloud builds log BUILD_ID
   ```

3. Check pod status and logs:
   ```bash
   kubectl get pods -n microservices-app
   kubectl logs -n microservices-app POD_NAME
   ``` 