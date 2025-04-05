# Setting up GitHub Actions with GKE and Workload Identity Federation

This guide explains how to connect your GitHub Actions workflow to your Google Kubernetes Engine (GKE) cluster using Workload Identity Federation.

## Prerequisites

- A GitHub repository with your microservices code
- A GKE cluster (already set up with Terraform)
- Terraform installed and configured with Google Cloud credentials

## Step 1: Apply Terraform Configuration

We've created a Terraform configuration that sets up all the necessary resources for GitHub Actions to authenticate with GKE and GCR.

```bash
cd terraform
terraform apply
```

## Step 2: Capture Terraform Output Values

After applying the Terraform configuration, note the following output values:
- `service_account_email`
- `workload_identity_provider`
- `artifact_registry_location`

## Step 3: Configure GitHub Repository Secrets

Add the following secrets to your GitHub repository:

1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:
   - `WORKLOAD_IDENTITY_PROVIDER`: The value of the `workload_identity_provider` output
   - `SERVICE_ACCOUNT_EMAIL`: The value of the `service_account_email` output

## Step 4: Update GitHub Repository Settings

1. In your repository settings, ensure that the workflow has permission to request the ID token:
   - Go to Settings > Actions > General
   - Scroll down to "Workflow permissions"
   - Enable "Allow GitHub Actions to create and approve pull requests"
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to request the ID token"

## Step 5: Update Terraform Configuration with Your GitHub Username

Edit the `terraform/github-actions-auth.tf` file and replace `REPLACE_WITH_YOUR_GITHUB_USERNAME` with your actual GitHub username in the `github_owner` variable.

```hcl
variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
  default     = "YOUR_ACTUAL_GITHUB_USERNAME"
}
```

Then apply the Terraform changes:

```bash
terraform apply
```

## Step 6: Test the Workflow

Commit and push a change to your repository to trigger the workflow. Check the Actions tab to see if the workflow runs successfully.

## Troubleshooting

### Authentication Issues

If you encounter authentication issues:

1. Verify the secrets are correctly set in your GitHub repository
2. Check that the service account has the correct permissions
3. Ensure the Workload Identity Provider is correctly configured
4. Verify that your GitHub username is correctly set in the Terraform configuration

### Deployment Issues

If deployments fail:

1. Check the GKE cluster is running and accessible
2. Verify that your Kubernetes manifests are correctly formatted
3. Check that the service account has the correct permissions to deploy to GKE

## Additional Configuration

### Adding More Microservices

To add more microservices to your workflow, update the `.github/workflows/deploy.yaml` file with additional build and push steps, and update the deployment rollout status checks.

### Adding Testing Steps

Consider adding testing steps to your workflow before deployment:

```yaml
- name: Run Tests
  run: mvn test
```

### Configuring Branch Protection

For additional security, configure branch protection rules for your main branch to require successful workflow runs before merging pull requests. 