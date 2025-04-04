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