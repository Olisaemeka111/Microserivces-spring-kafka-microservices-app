# Resource-Reduced Kubernetes Deployments

These files contain reduced resource requests to help with deployment on resource-constrained clusters where quota limits might be an issue.

## Changes Made

- Reduced CPU requests from 250m to 50m (80% reduction)
- Reduced memory requests from 512Mi to 128Mi (75% reduction)
- Reduced CPU limits from 500m to 100m (80% reduction)
- Reduced memory limits from 1Gi to 256Mi (75% reduction)

## How to Apply

Apply these reduced resource manifests in the following order:

```bash
# 1. Apply namespace
kubectl apply -f namespace.yaml

# 2. Apply infrastructure components with reduced resources
kubectl apply -f optimized-infrastructure-reduced.yaml

# 3. Apply discovery server with reduced resources
kubectl apply -f discovery-server.yaml

# 4. Apply microservices with reduced resources
kubectl apply -f optimized-resources-reduced.yaml
```

## Notes

- These reduced resource allocations may impact application performance
- Monitor the applications after deployment to ensure they're functioning properly
- If experiencing out-of-memory issues, you may need to increase memory allocations
- This is a temporary solution until you can request higher quota limits for your GCP project 