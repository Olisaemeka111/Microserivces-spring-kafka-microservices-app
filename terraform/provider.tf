provider "google" {
  project = var.project_id
  region  = var.region
}

# Get Google client configuration for authentication
data "google_client_config" "default" {}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Define a local variable to check if cluster exists
locals {
  cluster_exists = true # Set to true now that cluster is available
}

# Configure the Kubernetes Provider conditionally
provider "kubernetes" {
  host                   = local.cluster_exists ? "https://${google_container_cluster.primary.endpoint}" : ""
  token                  = local.cluster_exists ? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = local.cluster_exists ? base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate) : ""
  
  # Skip validation during plan phase
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "echo"
    args        = ["{}"]
  }
} 