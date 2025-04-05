# GCP Service Account and Workload Identity Federation Setup Guide

## Required IAM Roles

Ensure your service account has the following IAM roles:

1. `roles/container.developer` - For GKE access
2. `roles/artifactregistry.writer` - For pushing images
3. `roles/serviceusage.serviceUsageAdmin` - For enabling APIs
4. `roles/iam.serviceAccountUser` - For impersonating service accounts

## Setup Steps

1. Create a Workload Identity Pool:
```bash
gcloud iam workload-identity-pools create "github-actions-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Actions Pool"
```

2. Create a Workload Identity Provider:
```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-actions-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

3. Add IAM Policy Bindings:
```bash
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/container.developer"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
  --role="roles/iam.serviceAccountUser"
```

4. Allow the Workload Identity Provider to impersonate the service account:
```bash
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/${GITHUB_REPOSITORY}"
```

## GitHub Secrets

Add the following secrets to your GitHub repository:

- `WORKLOAD_IDENTITY_PROVIDER`: The full identifier of your Workload Identity Provider
- `SERVICE_ACCOUNT`: Your service account email
- `GCP_PROJECT_ID`: Your GCP project ID
- `GKE_CLUSTER`: Your GKE cluster name
- `GKE_ZONE`: Your GKE cluster zone