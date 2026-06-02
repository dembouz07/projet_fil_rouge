# Script de déploiement Kubernetes pour Portfolio (Windows)

Write-Host "🚀 Déploiement de l'application Portfolio sur Kubernetes..." -ForegroundColor Green

# Créer le namespace
Write-Host "`n📦 Création du namespace..." -ForegroundColor Cyan
kubectl apply -f namespace.yaml

# Déployer MongoDB
Write-Host "`n🗄️  Déploiement de MongoDB..." -ForegroundColor Cyan
kubectl apply -f mongodb-deployment.yaml

# Attendre que MongoDB soit prêt
Write-Host "`n⏳ Attente du démarrage de MongoDB..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mongodb -n portfolio --timeout=120s

# Déployer le Backend
Write-Host "`n⚙️  Déploiement du Backend..." -ForegroundColor Cyan
kubectl apply -f backend-deployment.yaml

# Attendre que le Backend soit prêt
Write-Host "`n⏳ Attente du démarrage du Backend..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend -n portfolio --timeout=120s

# Déployer le Frontend
Write-Host "`n🎨 Déploiement du Frontend..." -ForegroundColor Cyan
kubectl apply -f frontend-deployment.yaml

# Attendre que le Frontend soit prêt
Write-Host "`n⏳ Attente du démarrage du Frontend..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=frontend -n portfolio --timeout=120s

# Déployer l'Ingress
Write-Host "`n🌐 Configuration de l'Ingress..." -ForegroundColor Cyan
kubectl apply -f ingress.yaml

Write-Host "`n✅ Déploiement terminé avec succès!" -ForegroundColor Green

Write-Host "`n📊 État des pods:" -ForegroundColor Cyan
kubectl get pods -n portfolio

Write-Host "`n🔗 Services:" -ForegroundColor Cyan
kubectl get svc -n portfolio

Write-Host "`n🌍 Ingress:" -ForegroundColor Cyan
kubectl get ingress -n portfolio

Write-Host "`n💡 Pour accéder à l'application:" -ForegroundColor Yellow
Write-Host "   Ajoutez cette ligne à votre fichier hosts (C:\Windows\System32\drivers\etc\hosts):"
Write-Host "   127.0.0.1 portfolio.local" -ForegroundColor White
Write-Host "`n   Puis accédez à: http://portfolio.local" -ForegroundColor White
