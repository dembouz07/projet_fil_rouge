#!/bin/bash

# Script de déploiement Kubernetes pour Portfolio

echo "🚀 Déploiement de l'application Portfolio sur Kubernetes..."

# Créer le namespace
echo "📦 Création du namespace..."
kubectl apply -f namespace.yaml

# Déployer MongoDB
echo "🗄️  Déploiement de MongoDB..."
kubectl apply -f mongodb-deployment.yaml

# Attendre que MongoDB soit prêt
echo "⏳ Attente du démarrage de MongoDB..."
kubectl wait --for=condition=ready pod -l app=mongodb -n portfolio --timeout=120s

# Déployer le Backend
echo "⚙️  Déploiement du Backend..."
kubectl apply -f backend-deployment.yaml

# Attendre que le Backend soit prêt
echo "⏳ Attente du démarrage du Backend..."
kubectl wait --for=condition=ready pod -l app=backend -n portfolio --timeout=120s

# Déployer le Frontend
echo "🎨 Déploiement du Frontend..."
kubectl apply -f frontend-deployment.yaml

# Attendre que le Frontend soit prêt
echo "⏳ Attente du démarrage du Frontend..."
kubectl wait --for=condition=ready pod -l app=frontend -n portfolio --timeout=120s

# Déployer l'Ingress
echo "🌐 Configuration de l'Ingress..."
kubectl apply -f ingress.yaml

echo ""
echo "✅ Déploiement terminé avec succès!"
echo ""
echo "📊 État des pods:"
kubectl get pods -n portfolio

echo ""
echo "🔗 Services:"
kubectl get svc -n portfolio

echo ""
echo "🌍 Ingress:"
kubectl get ingress -n portfolio

echo ""
echo "💡 Pour accéder à l'application:"
echo "   Ajoutez cette ligne à votre fichier hosts:"
echo "   127.0.0.1 portfolio.local"
echo ""
echo "   Puis accédez à: http://portfolio.local"
