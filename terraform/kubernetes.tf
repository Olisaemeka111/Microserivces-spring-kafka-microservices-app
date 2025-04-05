# This file contains Kubernetes resources that will be applied after the cluster is created
# The variable cluster_exists should be set to true once the cluster is available

# Create namespace for microservices
resource "kubernetes_namespace" "microservices_app" {
  count = local.cluster_exists ? 1 : 0
  
  metadata {
    name = "microservices-app"
  }
  
  depends_on = [
    google_container_cluster.primary
  ]
}

# Set resource quotas for microservices namespace
resource "kubernetes_resource_quota" "microservices_quota" {
  count = local.cluster_exists ? 1 : 0
  
  metadata {
    name      = "microservices-quota"
    namespace = "microservices-app"
  }
  
  spec {
    hard = {
      "pods"            = 50
      "requests.cpu"    = "10"
      "requests.memory" = "20Gi"
      "limits.cpu"      = "20"
      "limits.memory"   = "40Gi"
    }
  }
  
  depends_on = [
    kubernetes_namespace.microservices_app
  ]
}

# Set default resource limits for containers
resource "kubernetes_limit_range" "microservices_limits" {
  count = local.cluster_exists ? 1 : 0
  
  metadata {
    name      = "microservices-limits"
    namespace = "microservices-app"
  }
  
  spec {
    limit {
      type = "Container"
      
      default = {
        cpu    = "200m"
        memory = "512Mi"
      }
      
      default_request = {
        cpu    = "100m"
        memory = "256Mi"
      }
      
      max = {
        cpu    = "1000m"
        memory = "1024Mi"
      }
      
      min = {
        cpu    = "10m"
        memory = "64Mi"
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.microservices_app
  ]
}

# Variable to check if deployments are available
# This should be set to true only after the microservices are deployed
locals {
  deployments_available = false  # Set to false since api-gateway deployment doesn't exist yet
}

# Configure horizontal pod autoscaler for API Gateway
resource "kubernetes_horizontal_pod_autoscaler" "api_gateway_hpa" {
  count = local.cluster_exists && local.deployments_available ? 1 : 0
  
  metadata {
    name      = "api-gateway-hpa"
    namespace = "microservices-app"
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "api-gateway"
    }
    
    min_replicas = 2
    max_replicas = 6
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.microservices_app
  ]
} 