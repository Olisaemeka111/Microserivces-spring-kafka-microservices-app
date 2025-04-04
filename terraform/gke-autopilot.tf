provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the cluster"
  default     = "us-central1"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  default     = "microservices-autopilot"
  type        = string
}

# VPC Network for the GKE cluster
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

# Subnet for the GKE cluster
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/18"
  
  # Secondary IP ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.48.0.0/14"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# Create GKE Autopilot cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  # Enable Autopilot mode
  enable_autopilot = true
  
  # Set to regional cluster for higher availability
  node_locations = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c"
  ]
  
  # Network configuration
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Autopilot clusters require release channel
  release_channel {
    channel = "REGULAR"
  }
  
  # Workload Identity for better security
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Medium resource settings (Note: Autopilot automatically scales nodes based on workload requirements)
  vertical_pod_autoscaling {
    enabled = true
  }
  
  # Network security
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "All IPs"
      cidr_block   = "0.0.0.0/0"
    }
  }
  
  # Private cluster config
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# Create Cloud NAT for private GKE nodes to access the internet
resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "region" {
  value = var.region
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
} 