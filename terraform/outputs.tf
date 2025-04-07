output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = data.google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = data.google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate (base64 encoded)"
  value       = data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  value = var.region
}

output "get_credentials_command" {
  description = "Command to get GKE cluster credentials"
  value       = "gcloud container clusters get-credentials ${data.google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
} 