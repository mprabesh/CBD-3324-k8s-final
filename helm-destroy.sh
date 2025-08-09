#!/bin/bash

# Blog K8s Deployment - Helm Uninstall Script
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
RELEASE_NAME="blog-k8s"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE} Blog K8s Deployment - Helm Uninstall   ${NC}"
echo -e "${BLUE} Maintainer: PRABESH MAGAR             ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ Helm is not installed.${NC}"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not available.${NC}"
    exit 1
fi

# Check if release exists
if ! helm list -q | grep -q "^$RELEASE_NAME$"; then
    echo -e "${YELLOW}⚠️  Release '$RELEASE_NAME' not found.${NC}"
    echo -e "${BLUE}Current releases:${NC}"
    helm list
    exit 0
fi

echo -e "${YELLOW}📋 Release Information:${NC}"
helm status "$RELEASE_NAME"

echo
echo -e "${YELLOW}⚠️  This will completely remove the Blog K8s application and all its data.${NC}"
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚫 Uninstall cancelled.${NC}"
    exit 0
fi

# Show resources before deletion
echo -e "${YELLOW}📋 Resources to be deleted:${NC}"
echo -e "${BLUE}Namespaces:${NC}"
kubectl get namespaces -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null || echo "None found"

echo -e "${BLUE}Deployments:${NC}"
kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null || echo "None found"

echo -e "${BLUE}Services:${NC}"
kubectl get services -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null || echo "None found"

echo -e "${BLUE}Secrets:${NC}"
kubectl get secrets -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null || echo "None found"

echo
echo -e "${YELLOW}🗑️  Uninstalling Helm release...${NC}"
if helm uninstall "$RELEASE_NAME" --wait --timeout=5m; then
    echo -e "${GREEN}✅ Helm release uninstalled successfully${NC}"
else
    echo -e "${RED}❌ Helm uninstall failed${NC}"
    exit 1
fi

# Check for remaining namespaces
echo -e "${YELLOW}🔍 Checking for remaining namespaces...${NC}"
REMAINING_NS=$(kubectl get namespaces -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING_NS" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some namespaces may still exist:${NC}"
    kubectl get namespaces -l app.kubernetes.io/instance="$RELEASE_NAME"
    echo
    read -p "Do you want to force delete remaining namespaces? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  Force deleting remaining namespaces...${NC}"
        kubectl get namespaces -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers | awk '{print $1}' | xargs -I {} kubectl delete namespace {} --force --grace-period=0 --timeout=60s
    fi
else
    echo -e "${GREEN}✅ All namespaces cleaned up${NC}"
fi

# Final verification
echo
echo -e "${YELLOW}🔍 Final verification...${NC}"
echo -e "${BLUE}Checking for any remaining resources:${NC}"

REMAINING_DEPLOYMENTS=$(kubectl get deployments -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | wc -l)
REMAINING_SERVICES=$(kubectl get services -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | wc -l)
REMAINING_SECRETS=$(kubectl get secrets -A -l app.kubernetes.io/instance="$RELEASE_NAME" --no-headers 2>/dev/null | wc -l)

if [ "$REMAINING_DEPLOYMENTS" -eq 0 ] && [ "$REMAINING_SERVICES" -eq 0 ] && [ "$REMAINING_SECRETS" -eq 0 ]; then
    echo -e "${GREEN}✅ All resources successfully removed${NC}"
else
    echo -e "${YELLOW}⚠️  Some resources may still exist:${NC}"
    [ "$REMAINING_DEPLOYMENTS" -gt 0 ] && echo -e "Deployments: $REMAINING_DEPLOYMENTS"
    [ "$REMAINING_SERVICES" -gt 0 ] && echo -e "Services: $REMAINING_SERVICES"
    [ "$REMAINING_SECRETS" -gt 0 ] && echo -e "Secrets: $REMAINING_SECRETS"
fi

echo
echo -e "${GREEN}🎉 Blog K8s uninstall completed!${NC}"
echo
echo -e "${YELLOW}📋 To redeploy:${NC}"
echo -e "• Use: ${BLUE}./helm-deploy.sh${NC}"
echo -e "• Or: ${BLUE}helm install blog-k8s ./helm-chart/blog-app${NC}"
echo
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN} Uninstall completed by PRABESH MAGAR   ${NC}"
echo -e "${BLUE}=========================================${NC}"
