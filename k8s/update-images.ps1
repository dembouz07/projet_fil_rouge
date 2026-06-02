# Script pour mettre à jour les images dans les déploiements Kubernetes
# Usage: .\update-images.ps1 -Version "v1.0.26"

param(
    [string]$Version = "latest"
)

$BACKEND_IMAGE = "dembouz7/portfolio-backend:$Version"
$FRONTEND_IMAGE = "dembouz7/portfolio-frontend:$Version"

Write-Host "🔄 Mise à jour des images Kubernetes..." -ForegroundColor Cyan
Write-Host "📦 Backend: $BACKEND_IMAGE" -ForegroundColor Yellow
Write-Host "📦 Frontend: $FRONTEND_IMAGE" -ForegroundColor Yellow
Write-Host ""

try {
    # Mettre à jour les déploiements
    Write-Host "⚙️  Mise à jour du backend..." -ForegroundColor Cyan
    kubectl set image deployment/backend backend=$BACKEND_IMAGE -n portfolio
    
    Write-Host "⚙️  Mise à jour du frontend..." -ForegroundColor Cyan
    kubectl set image deployment/frontend frontend=$FRONTEND_IMAGE -n portfolio
    
    # Attendre que les rolling updates soient terminés
    Write-Host "`n⏳ Attente du rolling update backend..." -ForegroundColor Yellow
    kubectl rollout status deployment/backend -n portfolio --timeout=300s
    
    Write-Host "⏳ Attente du rolling update frontend..." -ForegroundColor Yellow
    kubectl rollout status deployment/frontend -n portfolio --timeout=300s
    
    Write-Host "`n✅ Mise à jour terminée avec succès!" -ForegroundColor Green
    Write-Host "`n📊 État actuel des pods:" -ForegroundColor Cyan
    kubectl get pods -n portfolio
    
    Write-Host "`n🌐 Application accessible sur: http://portfolio.local" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Erreur lors de la mise à jour: $_" -ForegroundColor Red
    exit 1
}
