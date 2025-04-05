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
  default     = "spring-kafka-cluster"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC network"
  default     = "spring-kafka-cluster-vpc"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  default     = "spring-kafka-cluster-subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  default     = "10.0.0.0/18"
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
  default     = "REPLACE_WITH_YOUR_GITHUB_USERNAME"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "spring-kafka-microservices-app"
}

variable "deployments_available" {
  description = "Whether the Kubernetes deployments are available"
  type        = bool
  default     = false
}

variable "cluster_exists" {
  description = "Whether the GKE cluster already exists"
  type        = bool
  default     = true
} 