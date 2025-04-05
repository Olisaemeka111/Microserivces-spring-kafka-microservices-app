# GKE Autopilot Cluster Optimization Guide

This document provides optimization strategies for running your microservices on the GKE Autopilot cluster.

## Autopilot Resource Management

GKE Autopilot automatically manages the underlying infrastructure based on your pod resource requests and limits. To optimize your deployment:

### 1. Right-Size Pod Resources

We've already created resource-reduced manifests in the `k8s/` directory:

```yaml
# Example from optimized-resources-reduced.yaml
resources:
  requests:
    cpu: 50m
    memory: 128Mi
  limits:
    cpu: 100m
    memory: 256Mi
```

### 2. Configure Horizontal Pod Autoscaling (HPA)

Add HPA to automatically scale your services based on CPU/memory usage:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
  namespace: microservices-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 3. Optimize Container Images

- Use distroless or alpine-based images
- Implement multi-stage builds
- Remove development dependencies

### 4. Implement Resource Quotas

Apply namespace resource quotas to prevent runaway costs:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: microservices-quota
  namespace: microservices-app
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "4Gi"
    limits.cpu: "4"
    limits.memory: "8Gi"
    pods: "20"
```

### 5. Configure Default Resources with LimitRange

Create a LimitRange to set default resources for containers without explicit requests/limits:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: microservices-app
spec:
  limits:
  - type: Container
    default:
      cpu: 200m
      memory: 512Mi
    defaultRequest:
      cpu: 50m
      memory: 128Mi
    max:
      cpu: 500m
      memory: 1Gi
```

### 6. Use Pod Disruption Budgets (PDBs)

Protect critical services during cluster updates:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-gateway-pdb
  namespace: microservices-app
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: api-gateway
```

### 7. Implement Readiness and Liveness Probes

Add effective health checks to ensure only healthy pods receive traffic:

```yaml
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 20
```

### 8. Monitor Resource Usage

Regularly check resource usage with:

```bash
kubectl top pods -n microservices-app
kubectl describe resourcequota -n microservices-app
```

### 9. Use Cost Optimization Tools

- Enable GKE cost allocation for namespace tracking
- Set up budget alerts in Google Cloud
- Consider using tools like Kubecost for detailed analysis

## GKE Autopilot Specific Recommendations

1. **Use Stable APIs**: Avoid alpha/beta Kubernetes APIs
2. **Set Pod Priorities**: Critical services should have higher priority
3. **Optimize Release Strategy**: Use STABLE channel for production workloads
4. **Right-size Initial Cluster**: Start with a regional 3-zone cluster as configured
5. **Configure Workload Identity**: Already enabled for secure access to GCP services
