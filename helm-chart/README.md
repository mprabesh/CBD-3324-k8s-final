# Blog K8s Deployment - Helm Chart

**Maintainer:** PRABESH MAGAR  
**Repository:** mprabesh/CBD-3324-k8s-final  
**Course:** CBD-3324  
**Date:** 2025-08-09

This directory contains a Helm chart for deploying the Blog K8s application with enterprise-grade multi-namespace architecture.

## Quick Start

### Prerequisites

- Kubernetes cluster (v1.20+)
- Helm 3.x installed
- kubectl configured to access your cluster

### Installation

```bash
# Deploy the application
./helm-deploy.sh

# Or manually with Helm
helm install blog-k8s ./helm-chart/blog-app --create-namespace --wait
```

### Uninstallation

```bash
# Remove the application
./helm-destroy.sh

# Or manually with Helm
helm uninstall blog-k8s
```

## Architecture

The chart deploys a multi-tier application across 4 namespaces:

- **blog-frontend**: Frontend service (Vite application)
- **blog-application**: Backend API service (Node.js)
- **blog-cache**: Redis caching layer
- **blog-database**: MongoDB database

## Chart Structure

```
helm-chart/blog-app/
├── Chart.yaml                    # Chart metadata
├── values.yaml                   # Default configuration values
└── templates/
    ├── _helpers.tpl              # Template helpers
    ├── namespaces.yaml           # Namespace definitions
    ├── secrets.yaml              # Kubernetes secrets
    ├── mongodb-deployment.yaml   # MongoDB deployment
    ├── mongodb-service.yaml      # MongoDB service
    ├── redis-deployment.yaml    # Redis deployment
    ├── redis-service.yaml       # Redis service
    ├── backend-configmap.yaml   # Backend configuration
    ├── backend-deployment.yaml  # Backend deployment
    ├── backend-service.yaml     # Backend service
    └── frontend-configmap.yaml  # Frontend configuration
```

## Configuration

### Global Settings

```yaml
global:
  environment: production
  maintainer: "PRABESH MAGAR"
  repository: "mprabesh/CBD-3324-k8s-final"
  course: "CBD-3324"
  projectDate: "2025-08-09"
```

### Namespace Configuration

```yaml
namespaces:
  frontend: blog-frontend
  backend: blog-application
  cache: blog-cache
  database: blog-database
  create: true
```

### Application Components

#### Frontend (Vite App)
- **Image**: `magarp0723/blogapp-frontend:v9`
- **Replicas**: 3 (with HPA: 2-10)
- **Service**: LoadBalancer on port 80
- **Auto-scaling**: Based on CPU (70%) and Memory (80%)

#### Backend (Node.js API)
- **Image**: `magarp0723/blogapp-backend:v3`
- **Replicas**: 4
- **Service**: ClusterIP on port 8081
- **Init Container**: Database seeding
- **Health Checks**: `/health` endpoint

#### Redis Cache
- **Image**: `redis:7-alpine`
- **Replicas**: 1
- **Service**: ClusterIP on port 6379
- **Storage**: emptyDir volume

#### MongoDB Database
- **Image**: `mongo:7`
- **Replicas**: 1
- **Service**: ClusterIP on port 27017
- **Storage**: emptyDir volume
- **Authentication**: Root user with secrets

## Security Features

- **Kubernetes Secrets**: Base64-encoded credentials
- **Network Isolation**: Services use ClusterIP (internal only)
- **FQDN Communication**: Cross-namespace service discovery
- **Resource Limits**: CPU and memory constraints
- **Health Checks**: Liveness and readiness probes

## Deployment Scripts

### helm-deploy.sh
Comprehensive deployment script with:
- Pre-deployment validation
- Chart linting
- Installation or upgrade logic
- Resource verification
- Status reporting

### helm-destroy.sh
Safe uninstall script with:
- Confirmation prompts
- Resource enumeration
- Graceful cleanup
- Force deletion options
- Final verification

## Management Commands

```bash
# Check deployment status
helm status blog-k8s

# Upgrade the deployment
helm upgrade blog-k8s ./helm-chart/blog-app

# View deployed resources
kubectl get all -A -l app.kubernetes.io/instance=blog-k8s

# Check logs
kubectl logs -f deployment/blog-backend -n blog-application

# Scale components
kubectl scale deployment blog-frontend --replicas=5 -n blog-frontend

# Port forward for testing
kubectl port-forward service/blog-frontend-service 8080:80 -n blog-frontend
```

## Customization

### Override Values

Create a custom values file:

```yaml
# custom-values.yaml
frontend:
  replicas: 5
  autoscaling:
    minReplicas: 3
    maxReplicas: 15

backend:
  replicas: 6
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
```

Deploy with custom values:

```bash
helm install blog-k8s ./helm-chart/blog-app -f custom-values.yaml
```

### Environment-Specific Deployments

```bash
# Development environment
helm install blog-k8s-dev ./helm-chart/blog-app --set global.environment=development

# Staging environment
helm install blog-k8s-staging ./helm-chart/blog-app --set global.environment=staging
```

## Monitoring and Troubleshooting

### Health Checks

```bash
# Check all pods
kubectl get pods -A -l app.kubernetes.io/instance=blog-k8s

# Check services
kubectl get services -A -l app.kubernetes.io/instance=blog-k8s

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Logs

```bash
# Backend logs
kubectl logs -f deployment/blog-backend -n blog-application

# Frontend logs
kubectl logs -f deployment/blog-frontend -n blog-frontend

# Database logs
kubectl logs -f deployment/mongodb -n blog-database

# Cache logs
kubectl logs -f deployment/redis -n blog-cache
```

### Debug Connection Issues

```bash
# Test MongoDB connectivity
kubectl exec -it deployment/blog-backend -n blog-application -- nc -zv mongodb-service.blog-database.svc.cluster.local 27017

# Test Redis connectivity
kubectl exec -it deployment/blog-backend -n blog-application -- nc -zv redis-service.blog-cache.svc.cluster.local 6379

# Test backend API
kubectl exec -it deployment/blog-frontend -n blog-frontend -- curl blog-backend-service.blog-application.svc.cluster.local:8081/health
```

## Version History

- **v1.0.0**: Initial Helm chart implementation
  - Multi-namespace architecture
  - Enterprise security features
  - Auto-scaling capabilities
  - Comprehensive documentation

## Contributing

For issues, improvements, or questions:
1. Review the PROJECT_REPORT.md for detailed architecture
2. Check existing deploy.sh/destroy.sh for kubectl-based deployment
3. Contact maintainer: PRABESH MAGAR

## License

This project is part of course CBD-3324 and is maintained by PRABESH MAGAR.
