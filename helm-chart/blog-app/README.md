# Blog Application Helm Chart

**Maintainer:** PRABESH MAGAR  
**Repository:** mprabesh/CBD-3324-k8s-final  
**Course:** CBD-3324  
**Date:** 2025-08-09

## Chart Structure

This Helm chart deploys a complete blog application with a microservices architecture across multiple Kubernetes namespaces.

### Directory Organization

```
helm-chart/blog-app/
├── Chart.yaml                 # Chart metadata
├── values.yaml               # Configuration values
├── charts/                   # Chart dependencies
├── templates/                # Kubernetes manifests
│   ├── _helpers.tpl         # Template helpers
│   ├── frontend/            # Frontend component templates
│   │   ├── frontend-configmap.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-hpa.yaml
│   │   ├── frontend-ingress.yaml
│   │   └── frontend-service.yaml
│   ├── backend/             # Backend component templates
│   │   ├── backend-configmap.yaml
│   │   ├── backend-deployment.yaml
│   │   └── backend-service.yaml
│   ├── database/            # Database component templates
│   │   ├── mongodb-deployment.yaml
│   │   └── mongodb-service.yaml
│   ├── cache/               # Cache component templates
│   │   ├── redis-deployment.yaml
│   │   └── redis-service.yaml
│   └── shared/              # Shared resources
│       ├── namespaces.yaml
│       └── secrets.yaml
└── README.md                # This file
```

## Architecture Components

### 1. Frontend (`blog-frontend` namespace)
- **Technology:** Vite React Application
- **Image:** `magarp0723/blogapp-frontend:v9`
- **Scaling:** HPA enabled (2-10 replicas)
- **Access:** LoadBalancer service + Ingress
- **Environment Variables:**
  - `VITE_API_URL`: Backend API endpoint
  - `BACKEND_URL`: General backend URL reference

### 2. Backend (`blog-application` namespace)
- **Technology:** Node.js Application
- **Image:** `magarp0723/blogapp-backend:v3`
- **Scaling:** 4 replicas
- **Access:** ClusterIP (internal only)
- **Features:** Init container for database seeding

### 3. Database (`blog-database` namespace)
- **Technology:** MongoDB 7
- **Image:** `mongo:7`
- **Storage:** EmptyDir (development setup)
- **Authentication:** Username/password via Secrets

### 4. Cache (`blog-cache` namespace)
- **Technology:** Redis 7
- **Image:** `redis:7-alpine`
- **Persistence:** EmptyDir with AOF enabled

## Deployment

### Prerequisites
- Kubernetes 1.20+
- Helm 3.x
- kubectl configured

### Install
```bash
helm install blog-k8s ./helm-chart/blog-app --create-namespace --timeout=3m
```

### Upgrade
```bash
helm upgrade blog-k8s ./helm-chart/blog-app --timeout=3m
```

### Uninstall
```bash
helm uninstall blog-k8s
```

## Configuration

Key configuration options in `values.yaml`:

```yaml
frontend:
  enabled: true
  replicas: 3
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

backend:
  enabled: true
  replicas: 4

redis:
  enabled: true

mongodb:
  enabled: true
```

## Accessing the Application

1. **Via Ingress (Recommended):**
   ```bash
   # Add to /etc/hosts
   echo "127.0.0.1 blog.local" >> /etc/hosts
   # Access at: http://blog.local
   ```

2. **Via LoadBalancer:**
   ```bash
   kubectl get svc blog-frontend-service -n blog-frontend
   ```

3. **Via Port Forward:**
   ```bash
   kubectl port-forward svc/blog-frontend-service 3000:80 -n blog-frontend
   # Access at: http://localhost:3000
   ```

## Monitoring

```bash
# Check all resources
kubectl get all -A -l app.kubernetes.io/instance=blog-k8s

# Check pod logs
kubectl logs -f deployment/blog-backend -n blog-application
kubectl logs -f deployment/blog-frontend -n blog-frontend

# Check HPA status
kubectl get hpa -n blog-frontend
```

## Template Organization Benefits

1. **Component Isolation:** Each component's templates are grouped together
2. **Maintainability:** Easier to find and modify specific component resources
3. **Scalability:** Easy to add new components or services
4. **Team Collaboration:** Different teams can work on different component directories
5. **CI/CD Integration:** Selective deployment of components becomes possible

## Security Features

- Kubernetes Secrets for sensitive data
- Namespace isolation
- Network policies (configurable)
- Non-root containers
- Resource limits and requests

## Enterprise Features

- Multi-namespace architecture
- Horizontal Pod Autoscaling
- Health checks and probes
- ConfigMap-based configuration
- Helm-based deployment management
- Comprehensive monitoring and logging setup

---
**Maintained by PRABESH MAGAR**  
**Project:** CBD-3324 Kubernetes Final Assignment
