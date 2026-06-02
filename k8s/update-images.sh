#!/bin/bash

# Script pour mettre à jour les images dans les déploiements Kubernetes
# Usage: ./update-images.sh <version>

VERSION=${1:-latest}
BACKEND_IMAGE="dembouz7/portfolio-backend:${VERSION}"
FRONTEND_IMAGE="dembouz7/portfolio-frontend:${VERSION}"

echo "🔄 Mise à jour des images Kubernetes..."
echo "📦 Backend: ${BACKEND_IMAGE}"
echo "📦 Frontend: ${FRONTEND_IMAGE}"

# Mettre à jour les déploiements
kubectl set image deployment/backend backend=${BACKEND_IMAGE} -n portfolio
kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE} -n portfolio

# Attendre que les rolling updates soient terminés
echo "⏳ Attente du rolling update backend..."
kubectl rollout status deployment/backend -n portfolio --timeout=300s

echo "⏳ Attente du rolling update frontend..."
kubectl rollout status deployment/frontend -n portfolio --timeout=300s

echo "✅ Mise à jour terminée!"
echo ""
echo "📊 État actuel:"
kubectl get pods -n portfolio
