#!/bin/bash

#==============================================================================
# Blog Application Kubernetes Cleanup Script
#==============================================================================
# Project: Enterprise Multi-Namespace Blog Application
# Maintainer: PRABESH MAGAR
# Repository: mprabesh/CBD-3324-k8s-final
# Course: CBD-3324 (Kubernetes Final Project)
# Date: August 9, 2025
#==============================================================================

echo "🔥 Destroying Enterprise Multi-Namespace Deployment..."

echo "🌐 Deleting Frontend Layer (blog-frontend)..."
kubectl delete -f frontend/ || echo "Some frontend resources may not exist"

echo "🚀 Deleting Application Layer (blog-application)..."
kubectl delete -f backend/ || echo "Some backend resources may not exist"

echo "⚡ Deleting Cache Layer (blog-cache)..."
kubectl delete -f redis/ || echo "Some redis resources may not exist"

echo "📦 Deleting Database Layer (blog-database)..."
kubectl delete -f db/ || echo "Some database resources may not exist"

echo "⏳ Waiting for resources to terminate..."
kubectl wait --for=delete pod -l app=blog-frontend -n blog-frontend --timeout=300s || echo "Frontend pods deletion timeout"
kubectl wait --for=delete pod -l app=blog-backend -n blog-application --timeout=300s || echo "Backend pods deletion timeout"
kubectl wait --for=delete pod -l app=redis -n blog-cache --timeout=300s || echo "Redis pods deletion timeout"
kubectl wait --for=delete pod -l app=mongodb -n blog-database --timeout=300s || echo "MongoDB pods deletion timeout"

echo "🔍 Verifying destruction across namespaces..."

echo ""
echo "🌐 Frontend Namespace (blog-frontend):"
REMAINING_FRONTEND=$(kubectl get all -n blog-frontend --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING_FRONTEND" -eq 0 ]; then
    echo "✅ Frontend namespace is clean"
else
    echo "⚠️  $REMAINING_FRONTEND resources still in frontend namespace:"
    kubectl get all -n blog-frontend
fi

echo ""
echo "📦 Database Namespace (blog-database):"
REMAINING_DB=$(kubectl get all -n blog-database --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING_DB" -eq 0 ]; then
    echo "✅ Database namespace is clean"
else
    echo "⚠️  $REMAINING_DB resources still in database namespace:"
    kubectl get all -n blog-database
fi

echo ""
echo "⚡ Cache Namespace (blog-cache):"
REMAINING_CACHE=$(kubectl get all -n blog-cache --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING_CACHE" -eq 0 ]; then
    echo "✅ Cache namespace is clean"
else
    echo "⚠️  $REMAINING_CACHE resources still in cache namespace:"
    kubectl get all -n blog-cache
fi

echo ""
echo "🚀 Application Namespace (blog-application):"
REMAINING_APP=$(kubectl get all -n blog-application --no-headers 2>/dev/null | wc -l)
if [ "$REMAINING_APP" -eq 0 ]; then
    echo "✅ Application namespace is clean"
else
    echo "⚠️  $REMAINING_APP resources still in application namespace:"
    kubectl get all -n blog-application
fi

echo ""
echo ""
echo "🔒 Checking Network Policies:"
NP_FRONTEND=$(kubectl get networkpolicies -n blog-frontend --no-headers 2>/dev/null | wc -l)
NP_DB=$(kubectl get networkpolicies -n blog-database --no-headers 2>/dev/null | wc -l)
NP_CACHE=$(kubectl get networkpolicies -n blog-cache --no-headers 2>/dev/null | wc -l)
NP_APP=$(kubectl get networkpolicies -n blog-application --no-headers 2>/dev/null | wc -l)

if [ "$NP_FRONTEND" -eq 0 ] && [ "$NP_DB" -eq 0 ] && [ "$NP_CACHE" -eq 0 ] && [ "$NP_APP" -eq 0 ]; then
    echo "✅ All network policies deleted"
else
    echo "⚠️  Some network policies remain:"
    echo "  Frontend: $NP_FRONTEND, Database: $NP_DB, Cache: $NP_CACHE, Application: $NP_APP"
fi

echo ""
echo "🗑️  Optional: Delete namespaces completely?"
echo "Run these commands if you want to delete the namespaces:"
echo "  kubectl delete namespace blog-frontend"
echo "  kubectl delete namespace blog-database"
echo "  kubectl delete namespace blog-cache"
echo "  kubectl delete namespace blog-application"

echo ""
TOTAL_REMAINING=$((REMAINING_FRONTEND + REMAINING_DB + REMAINING_CACHE + REMAINING_APP))
if [ "$TOTAL_REMAINING" -eq 0 ]; then
    echo "🎉 Enterprise cluster destruction completed successfully!"
    echo "📋 Namespaces remain for future deployments"
else
    echo "⚠️  $TOTAL_REMAINING resources still remain across namespaces"
    echo "Some resources may still be terminating..."
fi

echo ""
echo "�️  Optional: Delete namespaces completely?"
echo "Run these commands if you want to delete the namespaces:"
echo "  kubectl delete namespace blog-database"
echo "  kubectl delete namespace blog-cache"
echo "  kubectl delete namespace blog-application"

echo ""
TOTAL_REMAINING=$((REMAINING_DB + REMAINING_CACHE + REMAINING_APP))
if [ "$TOTAL_REMAINING" -eq 0 ]; then
    echo "🎉 Enterprise cluster destruction completed successfully!"
    echo "📋 Namespaces remain for future deployments"
else
    echo "⚠️  $TOTAL_REMAINING resources still remain across namespaces"
    echo "Some resources may still be terminating..."
fi    

