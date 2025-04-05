# GitHub Actions Authentication for GKE and GCR
# This file sets up Workload Identity Federation between GitHub Actions and GCP

# Create a dedicated service account for GitHub Actions
resource "google_service_account" "github_actions" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  project      = var.project_id
}

# Grant the service account permissions to push to Container Registry
resource "google_project_iam_member" "gcr_push" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant the service account permissions to deploy to GKE
resource "google_project_iam_member" "gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Grant the service account permissions to use Artifact Registry
resource "google_project_iam_member" "artifact_registry_admin" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Get project information
data "google_project" "project" {
  project_id = var.project_id
}

# Create a Workload Identity Pool for GitHub
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
  project                   = var.project_id
}

# Create a Workload Identity Provider for GitHub Actions
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  attribute_mapping                  = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository_owner==\"${var.github_owner}\""
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  project = var.project_id
}

# Create IAM policy binding for service account impersonation
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

# Output the necessary values for GitHub Actions workflow
output "service_account_email" {
  value = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  value = "projects/${var.project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
}

output "artifact_registry_location" {
  value = "us-central1"
} 