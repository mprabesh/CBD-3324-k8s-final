#!/bin/bash

# Blog K8s Deployment - Helm Installation Script
# Maintainer: PRABESH MAGAR
# Repository: mprabesh/CBD-3324-k8s-final
# Course: CBD-3324
# Date: 2025-08-09

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="blog-system"
CHART_NAME="blog-app"
RELEASE_NAME="blog-k8s"
CHART_PATH="./helm-chart/blog-app"

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE} Blog K8s Deployment - Helm Installation ${NC}"
echo -e "${BLUE} Maintainer: PRABESH MAGAR              ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed. Please install Helm first.${NC}"
    echo -e "${YELLOW}Visit: https://helm.sh/docs/intro/install/${NC}"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not available. Please ensure Kubernetes is accessible.${NC}"
    exit 1
fi

# Check if the chart directory exists
if [ ! -d "$CHART_PATH" ]; then
    echo -e "${RED}❌ Helm chart not found at $CHART_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Pre-deployment Information:${NC}"
echo -e "Chart Path: $CHART_PATH"
echo -e "Release Name: $RELEASE_NAME"
echo -e "Chart Name: $CHART_NAME"
echo -e "Kubectl Context: $(kubectl config current-context)"
echo

# Validate the chart
echo -e "${YELLOW}🔍 Validating Helm chart...${NC}"
if helm lint "$CHART_PATH"; then
    echo -e "${GREEN}✅ Chart validation successful${NC}"
else
    echo -e "${RED}❌ Chart validation failed${NC}"
    exit 1
fi

# Check if release already exists
if helm list -q | grep -q "^$RELEASE_NAME$"; then
    echo -e "${YELLOW}⚠️  Release '$RELEASE_NAME' already exists. Upgrading...${NC}"
    
    # Upgrade the release
    echo -e "${YELLOW}🔄 Upgrading Helm release...${NC}"
    if helm upgrade "$RELEASE_NAME" "$CHART_PATH" --timeout=3m; then
        echo -e "${GREEN}✅ Helm release upgraded successfully${NC}"
    else
        echo -e "${RED}❌ Helm upgrade failed${NC}"
        echo -e "${YELLOW}🔍 Checking pod status for debugging:${NC}"
        kubectl get pods -A -l app.kubernetes.io/instance="$RELEASE_NAME" 2>/dev/null || echo "No pods found"
        echo -e "${YELLOW}💡 Check logs with: kubectl logs <pod-name> -n <namespace>${NC}"
        exit 1
    fi
else
    # Install the release
    echo -e "${YELLOW}🚀 Installing Helm release...${NC}"
    if helm install "$RELEASE_NAME" "$CHART_PATH" --create-namespace --timeout=3m; then
        echo -e "${GREEN}✅ Helm release installed successfully${NC}"
    else
        echo -e "${RED}❌ Helm installation failed${NC}"
        echo -e "${YELLOW}🔍 Checking pod status for debugging:${NC}"
        kubectl get pods -A -l app.kubernetes.io/instance="$RELEASE_NAME" 2>/dev/null || echo "No pods found"
        echo -e "${YELLOW}💡 Check logs with: kubectl logs <pod-name> -n <namespace>${NC}"
        exit 1
    fi
fi

# Get release status
echo -e "${YELLOW}📊 Release Status:${NC}"
helm status "$RELEASE_NAME"

echo
echo -e "${YELLOW}📋 Deployed Resources:${NC}"
echo -e "${BLUE}Namespaces:${NC}"
kubectl get namespaces -l app.kubernetes.io/instance="$RELEASE_NAME"

echo
echo -e "${BLUE}Deployments:${NC}"
kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME"

echo
echo -e "${BLUE}Services:${NC}"
kubectl get services -A -l app.kubernetes.io/instance="$RELEASE_NAME"

echo
echo -e "${BLUE}Secrets:${NC}"
kubectl get secrets -A -l app.kubernetes.io/instance="$RELEASE_NAME"

# Check if services are ready
echo
echo -e "${YELLOW}🔍 Checking service readiness...${NC}"

# Wait for deployments to be ready
echo -e "${YELLOW}⏳ Waiting for deployments to be ready (checking every 10s for up to 3 minutes)...${NC}"
TIMEOUT=180
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    READY_DEPLOYMENTS=$(kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME" -o jsonpath='{range .items[*]}{.status.readyReplicas}/{.spec.replicas} {end}' 2>/dev/null || echo "")
    TOTAL_DEPLOYMENTS=$(kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | wc -l)
    
    if [ "$TOTAL_DEPLOYMENTS" -gt 0 ]; then
        echo -e "${BLUE}📊 Deployment Status: $READY_DEPLOYMENTS${NC}"
        kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | while read line; do
            echo -e "${BLUE}  - $line${NC}"
        done
        
        # Check if all deployments are ready
        if kubectl wait --for=condition=available --timeout=1s deployment -A -l app.kubernetes.io/instance="$RELEASE_NAME" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ All deployments are ready!${NC}"
            break
        fi
    fi
    
    sleep 10
    ELAPSED=$((ELAPSED + 10))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo -e "${YELLOW}⚠️  Some deployments may not be ready yet. Check status manually.${NC}"
fi

echo
echo -e "${GREEN}🎉 Blog K8s deployment completed successfully!${NC}"
echo
echo -e "${YELLOW}📋 Deployment Summary:${NC}"
echo -e "${BLUE}Pods:${NC}"
kubectl get pods -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers | while read line; do
    echo -e "${BLUE}  - $line${NC}"
done

echo
echo -e "${BLUE}Services:${NC}"
kubectl get services -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers | while read line; do
    echo -e "${BLUE}  - $line${NC}"
done

echo
echo -e "${BLUE}Ingress:${NC}"
kubectl get ingress -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | while read line; do
    echo -e "${BLUE}  - $line${NC}"
done || echo -e "${YELLOW}  No ingress found${NC}"

echo
echo -e "${BLUE}HPA (Auto-scaling):${NC}"
kubectl get hpa -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | while read line; do
    echo -e "${BLUE}  - $line${NC}"
done || echo -e "${YELLOW}  No HPA found${NC}"

echo
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "1. Check all pods are running: ${BLUE}kubectl get pods -A -l app.kubernetes.io/instance=$RELEASE_NAME${NC}"
echo -e "2. Access the application via ingress: ${BLUE}http://blog.local${NC}"
echo -e "3. Access via LoadBalancer: ${BLUE}kubectl get svc blog-frontend-service -n blog-frontend${NC}"
echo -e "4. View logs: ${BLUE}kubectl logs -f deployment/<component-name> -n <namespace>${NC}"
echo -e "5. Monitor the application: ${BLUE}kubectl get all -A -l app.kubernetes.io/instance=$RELEASE_NAME${NC}"
echo
echo -e "${YELLOW}🔧 Management Commands:${NC}"
echo -e "• Upgrade: ${BLUE}helm upgrade $RELEASE_NAME $CHART_PATH${NC}"
echo -e "• Rollback: ${BLUE}helm rollback $RELEASE_NAME${NC}"
echo -e "• Uninstall: ${BLUE}helm uninstall $RELEASE_NAME${NC}"
echo -e "• Status: ${BLUE}helm status $RELEASE_NAME${NC}"
echo
echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN} Deployment completed by PRABESH MAGAR   ${NC}"
echo -e "${BLUE}==========================================${NC}"
