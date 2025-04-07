# Configure Google Cloud providers
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Get Google client configuration for authentication
data "google_client_config" "default" {}

# Get existing cluster data
data "google_container_cluster" "my_cluster" {
  name     = "spring-kafka-cluster"
  location = var.region
  project  = var.project_id
}

# Define local variables
locals {
  cluster_exists = true # Set to true since we're using an existing cluster
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
} 