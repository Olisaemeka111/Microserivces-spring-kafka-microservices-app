# GKE Autopilot Terraform Deployment

This Terraform configuration creates a GKE Autopilot cluster optimized for microservices deployment with medium resource requirements.

## Features

- GKE Autopilot cluster with regional configuration for high availability
- Private GKE cluster with Cloud NAT for internet access
- VPC with custom subnets and secondary ranges for pods and services
- Workload Identity enabled for enhanced security
- Vertical Pod Autoscaling for optimized resource usage
- GitHub Actions integration with Workload Identity Federation

## File Structure

The Terraform configuration is organized into the following files:

- `main.tf` - Contains the main infrastructure resources (VPC, GKE cluster, etc.)
- `variables.tf` - Defines the input variables for the configuration
- `outputs.tf` - Defines the output values from the infrastructure deployment
- `provider.tf` - Contains provider configuration settings
- `versions.tf` - Specifies Terraform and provider version requirements
- `terraform.tfvars` - Contains the actual values for the variables
- `github-actions-auth.tf` - Sets up authentication between GitHub Actions and GKE

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0+)
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. A Google Cloud Platform project with the following APIs enabled:
   - Compute Engine API
   - Kubernetes Engine API
   - Container Registry API
   - IAM API
   - IAM Credentials API

## Usage

1. Update the `terraform.tfvars` file with your configuration values:

   ```hcl
   # Project settings
   project_id = "your-gcp-project-id"
   
   # GitHub configuration - IMPORTANT for GitHub Actions integration
   github_owner = "your-github-username-or-org"
   github_repo = "your-repository-name"
   
   # GKE cluster configuration
   region = "us-central1"
   cluster_name = "spring-kafka-cluster"
   
   # Network configuration
   vpc_name = "spring-kafka-cluster-vpc"
   subnet_name = "spring-kafka-cluster-subnet"
   subnet_cidr = "10.0.0.0/18"
   
   # Deployments configuration
   deployments_available = false
   cluster_exists = true
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Capture the GitHub Actions authentication outputs:
   ```bash
   terraform output service_account_email
   terraform output workload_identity_provider
   ```

6. Add these outputs as secrets in your GitHub repository:
   - `SERVICE_ACCOUNT_EMAIL`: The value from the service_account_email output
   - `WORKLOAD_IDENTITY_PROVIDER`: The value from the workload_identity_provider output

7. Connect to your new cluster:
   ```bash
   gcloud container clusters get-credentials spring-kafka-cluster --region us-central1 --project YOUR_PROJECT_ID
   ```

## GitHub Actions Integration

This configuration includes Workload Identity Federation for GitHub Actions, allowing your CI/CD pipeline to securely deploy to your GKE cluster without storing Google Cloud credentials.

To complete the GitHub Actions setup:

1. Make sure you've set your actual GitHub username in the `github_owner` variable in `terraform.tfvars`.
2. Apply the Terraform configuration.
3. Add the service account email and workload identity provider outputs as GitHub repository secrets.
4. Ensure your GitHub repository is set to allow ID token requests in Repository Settings > Actions > General.

See the detailed instructions in `../docs/GITHUB_GKE_SETUP.md` for more information.

## Deploying Microservices

After the cluster is created, you can deploy your microservices using:

```bash
kubectl apply -f ../k8s/namespace.yaml
kubectl apply -f ../k8s/optimized-infrastructure-reduced.yaml
kubectl apply -f ../k8s/discovery-server.yaml
kubectl apply -f ../k8s/optimized-resources-reduced.yaml
```

## Resource Considerations

GKE Autopilot automatically provisions and scales the underlying infrastructure based on your workload's resource requests. This configuration is designed for medium resource usage, which should be sufficient for running your Spring Kafka microservices.

If you experience resource constraints:

1. Use the resource-reduced Kubernetes manifests (already created in your project)
2. Adjust resource quotas in the GKE console as needed
3. Consider upgrading to a larger machine type if consistently requiring more resources

## Clean Up

To destroy the cluster and associated resources:

```bash
terraform destroy
``` 