# GKE Autopilot Terraform Deployment

This Terraform configuration creates a GKE Autopilot cluster optimized for microservices deployment with medium resource requirements.

## Features

- GKE Autopilot cluster with regional configuration for high availability
- Private GKE cluster with Cloud NAT for internet access
- VPC with custom subnets and secondary ranges for pods and services
- Workload Identity enabled for enhanced security
- Vertical Pod Autoscaling for optimized resource usage

## File Structure

The Terraform configuration is organized into the following files:

- `main.tf` - Contains the main infrastructure resources (VPC, GKE cluster, etc.)
- `variables.tf` - Defines the input variables for the configuration
- `outputs.tf` - Defines the output values from the infrastructure deployment
- `provider.tf` - Contains provider configuration settings
- `versions.tf` - Specifies Terraform and provider version requirements
- `terraform.tfvars` - Contains the actual values for the variables

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0+)
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. A Google Cloud Platform project with the following APIs enabled:
   - Compute Engine API
   - Kubernetes Engine API
   - Container Registry API

## Usage

1. Update the `terraform.tfvars` file with your project ID and desired region.

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

5. Connect to your new cluster:
   ```bash
   gcloud container clusters get-credentials spring-kafka-cluster --region us-central1 --project YOUR_PROJECT_ID
   ```

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