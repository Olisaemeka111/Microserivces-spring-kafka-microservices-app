# VPC Network for the GKE cluster
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      auto_create_subnetworks,
    ]
  }
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
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      secondary_ip_range,
    ]
  }
}

# Create GKE Autopilot cluster optimized for microservices with lower resource requirements
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  
  # Enable Autopilot mode for simplified management
  enable_autopilot = true
  
  # Use all three zones for increased capacity and high availability
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
  
  # Use STABLE channel for better reliability with resource-constrained workloads
  release_channel {
    channel = "STABLE"
  }
  
  # Workload Identity for better security
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Enable vertical pod autoscaling for efficient resource allocation
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
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      node_locations,
      ip_allocation_policy,
      master_authorized_networks_config,
    ]
  }
}

# Create Cloud NAT for private GKE nodes to access the internet
resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-router"
  region  = var.region
  network = google_compute_network.vpc.name
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Create Artifact Registry repository for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  location      = var.region
  repository_id = "spring-kafka-microservices"
  description   = "Docker repository for Spring Kafka Microservices"
  format        = "DOCKER"
}

# Grant the GitHub Actions service account permission to push to Artifact Registry
resource "google_artifact_registry_repository_iam_member" "github_actions_writer" {
  provider   = google
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
  
  depends_on = [
    google_service_account.github_actions,
    google_artifact_registry_repository.docker_repo
  ]
} 