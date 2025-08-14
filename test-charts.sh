#!/bin/bash

# Helm Chart Testing Script
# Maintainer: PRABESH MAGAR
# Repository: mprabesh/CBD-3324-k8s-final

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  Testing Helm Charts Before ArgoCD Deploy ${NC}"
echo -e "${BLUE}============================================${NC}"

# Function to test a chart
test_chart() {
    local chart_path=$1
    local chart_name=$(basename "$chart_path")
    
    echo -e "${YELLOW}🧪 Testing $chart_name chart...${NC}"
    
    # Lint the chart
    if helm lint "$chart_path"; then
        echo -e "${GREEN}✅ $chart_name lint passed${NC}"
    else
        echo -e "${RED}❌ $chart_name lint failed${NC}"
        return 1
    fi
    
    # Test template rendering
    if helm template "test-$chart_name" "$chart_path" --debug > /dev/null; then
        echo -e "${GREEN}✅ $chart_name template rendering passed${NC}"
    else
        echo -e "${RED}❌ $chart_name template rendering failed${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📋 Resources that will be created:${NC}"
    helm template "test-$chart_name" "$chart_path" | grep "^kind:" | sort | uniq -c
    echo
}

# Test all charts
CHARTS=("helm-charts/frontend" "helm-charts/backend" "helm-charts/database" "helm-charts/cache")

for chart in "${CHARTS[@]}"; do
    if [ -d "$chart" ]; then
        test_chart "$chart"
    else
        echo -e "${YELLOW}⚠️  Chart directory $chart not found, skipping...${NC}"
    fi
done

echo -e "${GREEN}🎉 All chart tests completed!${NC}"
echo
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo -e "${BLUE}1. Deploy to ArgoCD: kubectl apply -f argocd/database-app.yaml${NC}"
echo -e "${BLUE}2. Monitor deployment: kubectl get applications -n argocd${NC}"
echo -e "${BLUE}3. Check resources: kubectl get all -n blog-database${NC}"
echo
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}  Testing completed by PRABESH MAGAR       ${NC}"
echo -e "${BLUE}============================================${NC}"
