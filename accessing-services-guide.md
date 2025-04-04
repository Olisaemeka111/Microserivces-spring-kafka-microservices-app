# Accessing Your Microservices on GKE

## Current Service Configuration

Your microservices are currently configured with `ClusterIP` service type, which means they're only accessible within the Kubernetes cluster. To access them from outside the cluster, you have several options:

## Option 1: Create an Ingress Controller

An Ingress controller provides HTTP/HTTPS routing to your services based on hostnames and paths.

1. Install NGINX Ingress Controller:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

2. Create an ingress resource (save as `k8s/ingress.yaml`):
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices-ingress
  namespace: microservices-app
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - path: /products
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 8080
      - path: /orders
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8081
      - path: /inventory
        pathType: Prefix
        backend:
          service:
            name: inventory-service
            port:
              number: 8082
      - path: /notifications
        pathType: Prefix
        backend:
          service:
            name: notification-service
            port:
              number: 8083
```

3. Apply the ingress configuration:
```bash
kubectl apply -f k8s/ingress.yaml
```

4. Get the external IP of the ingress controller:
```bash
kubectl get service -n ingress-nginx ingress-nginx-controller
```

The EXTERNAL-IP field will show the public IP address you can use to access your services.

## Option 2: Update Services to LoadBalancer Type

You can modify your service definitions to use LoadBalancer type, which will provision a Google Cloud Load Balancer for each service.

1. Update your services in `k8s/services.yaml`:
```yaml
# For each service, change:
spec:
  type: ClusterIP
  
# To:
spec:
  type: LoadBalancer
```

2. Apply the updated configuration:
```bash
kubectl apply -f k8s/services.yaml
```

3. Get the external IPs:
```bash
kubectl get services -n microservices-app
```

## Option 3: Use Port Forwarding for Development/Testing

For temporary access during development:

```bash
# For product-service
kubectl port-forward -n microservices-app svc/product-service 8080:8080

# For order-service
kubectl port-forward -n microservices-app svc/order-service 8081:8081

# For inventory-service
kubectl port-forward -n microservices-app svc/inventory-service 8082:8082

# For notification-service
kubectl port-forward -n microservices-app svc/notification-service 8083:8083
```

Then access the services at:
- Product Service: http://localhost:8080
- Order Service: http://localhost:8081
- Inventory Service: http://localhost:8082
- Notification Service: http://localhost:8083

## Service Discovery

Your microservices are using Eureka for service discovery. The Eureka server is configured at `discovery-server:8761/eureka` within the cluster.

To access the Eureka dashboard:

1. Port-forward the Eureka server (if you have one deployed):
```bash
kubectl port-forward -n microservices-app svc/discovery-server 8761:8761
```

2. Access the dashboard at http://localhost:8761

## Checking Deployment Status

To verify your deployment:

```bash
# Get all deployments
kubectl get deployments -n microservices-app

# Get all services
kubectl get services -n microservices-app

# Get all pods
kubectl get pods -n microservices-app

# Get detailed information about a specific pod
kubectl describe pod -n microservices-app <pod-name>

# View logs for a specific pod
kubectl logs -n microservices-app <pod-name>
```

## Accessing the GKE Cluster from Google Cloud Console

1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Navigate to Kubernetes Engine > Workloads
3. Select your cluster and namespace to view all deployed workloads
4. Click on a workload to see details, logs, and other information
