#!/bin/bash

#==============================================================================
# Blog Application Kubernetes Deployment Script
#==============================================================================
# Project: Enterprise Multi-Namespace Blog Application
# Maintainer: PRABESH MAGAR
# Repository: mprabesh/CBD-3324-k8s-final
# Course: CBD-3324 (Kubernetes Final Project)
# Date: August 9, 2025
#==============================================================================

echo "🏗️  Creating namespaces..."
kubectl apply -f db/namespace.yaml
kubectl apply -f redis/namespace.yaml
kubectl apply -f backend/namespace.yaml
kubectl apply -f frontend/namespace.yaml

echo "🔒 Deploying MongoDB (Database Layer)..."
kubectl apply -f db/secrets.yaml
kubectl apply -f db/deployment.yaml
kubectl apply -f db/service.yaml
kubectl apply -f db/network-policy.yaml

echo "⚡ Deploying Redis (Cache Layer)..."
kubectl apply -f redis/deployment.yaml
kubectl apply -f redis/service.yaml
kubectl apply -f redis/network-policy.yaml

echo "🚀 Deploying Backend (Application Layer)..."
kubectl apply -f backend/secrets.yaml
kubectl apply -f backend/configmap.yaml
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml
kubectl apply -f backend/network-policy.yaml

echo "⏳ Waiting for backend pods to be ready (including seeding)..."
kubectl wait --for=condition=ready pod -l app=blog-backend -n blog-application --timeout=600s

echo "🌐 Deploying Frontend (Presentation Layer)..."
kubectl apply -f frontend/configmap.yaml
kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml
kubectl apply -f frontend/network-policy.yaml
kubectl apply -f frontend/ingress.yaml
kubectl apply -f frontend/hpa.yaml

echo "⏳ Waiting for frontend pods to be ready..."
kubectl wait --for=condition=ready pod -l app=blog-frontend -n blog-frontend --timeout=300s

echo "✅ All services deployed successfully!"

echo "📊 Checking deployment status across namespaces..."

echo ""
echo "📦 Database Namespace (blog-database):"
kubectl get all -n blog-database

echo ""
echo "⚡ Cache Namespace (blog-cache):"
kubectl get all -n blog-cache

echo ""
echo "🚀 Application Namespace (blog-application):"
kubectl get all -n blog-application

echo ""
echo "🌐 Frontend Namespace (blog-frontend):"
kubectl get all -n blog-frontend

echo ""
echo "🔗 Ingress Information:"
kubectl get ingress -n blog-frontend

echo ""
echo "📈 HPA Status:"
kubectl get hpa -n blog-frontend

echo ""
echo "🔍 Checking init container logs (seeding)..."
kubectl logs -l app=blog-backend -c db-seeder -n blog-application --tail=20

echo ""
echo "🌍 Frontend Access:"
echo "If using NodePort: http://<node-ip>:<node-port>"
echo "If using LoadBalancer: Check 'kubectl get svc -n blog-frontend' for external IP"
echo "If using Ingress: Add '127.0.0.1 blog.local' to /etc/hosts, then visit http://blog.local"
