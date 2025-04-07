# Get existing VPC network
data "google_compute_network" "vpc" {
  name    = "spring-kafka-cluster-vpc"
  project = var.project_id
}

# Get existing subnet
data "google_compute_subnetwork" "subnet" {
  name    = "spring-kafka-cluster-subnet"
  region  = var.region
  project = var.project_id
}

# Get existing service account
data "google_service_account" "github_actions" {
  account_id = "github-actions-sa"
  project    = var.project_id
}

# Get existing GKE cluster
data "google_container_cluster" "primary" {
  name     = "spring-kafka-cluster"
  location = var.region
  project  = var.project_id
} 