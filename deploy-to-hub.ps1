# ============================================
# Script PowerShell de Déploiement vers Docker Hub
# ============================================

# Configuration
$DOCKER_USERNAME = "dembouz7"
$VERSION = "v1.0.0"
$DATE_TAG = Get-Date -Format "yyyyMMdd"

# Vous pouvez modifier ces valeurs :
# - DOCKER_USERNAME : votre username Docker Hub
# - VERSION : version de votre application (ex: v1.0.0, v1.1.0, v2.0.0)
# - DATE_TAG : tag avec la date (généré automatiquement)

# Fonction pour afficher les messages
function Print-Step {
    param($Message)
    Write-Host "==> $Message" -ForegroundColor Blue
}

function Print-Success {
    param($Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param($Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Warning {
    param($Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

# Banner
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🐳 Déploiement vers Docker Hub      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifier si le username est configuré
if ($DOCKER_USERNAME -eq "dembouz7") {
    Print-Warning "Username Docker Hub configuré : $DOCKER_USERNAME"
    Write-Host "Pour changer le username, modifiez la variable `$DOCKER_USERNAME dans le script"
    Write-Host ""
}

# 1. Vérifier Docker
Print-Step "Vérification de Docker..."
try {
    docker info | Out-Null
    Print-Success "Docker est opérationnel"
} catch {
    Print-Error "Docker n'est pas démarré ou n'est pas installé"
    exit 1
}

# 2. Connexion Docker Hub
Print-Step "Connexion à Docker Hub..."
docker login
if ($LASTEXITCODE -ne 0) {
    Print-Error "Échec de la connexion à Docker Hub"
    exit 1
}
Print-Success "Connecté à Docker Hub"

# 3. Build Backend
Print-Step "Build de l'image Backend..."
Set-Location express-js
docker build -t portfolio-backend:latest .
if ($LASTEXITCODE -ne 0) {
    Print-Error "Échec du build Backend"
    exit 1
}
Set-Location ..
Print-Success "Backend buildé avec succès"

# 4. Build Frontend
Print-Step "Build de l'image Frontend..."
Set-Location react-js
docker build -t portfolio-frontend:latest .
if ($LASTEXITCODE -ne 0) {
    Print-Error "Échec du build Frontend"
    exit 1
}
Set-Location ..
Print-Success "Frontend buildé avec succès"

# 5. Tag Backend
Print-Step "Tag de l'image Backend..."
docker tag portfolio-backend:latest "$DOCKER_USERNAME/portfolio-backend:latest"
docker tag portfolio-backend:latest "$DOCKER_USERNAME/portfolio-backend:$VERSION"
docker tag portfolio-backend:latest "$DOCKER_USERNAME/portfolio-backend:$DATE_TAG"
Print-Success "Backend taggé (latest, $VERSION, $DATE_TAG)"

# 6. Tag Frontend
Print-Step "Tag de l'image Frontend..."
docker tag portfolio-frontend:latest "$DOCKER_USERNAME/portfolio-frontend:latest"
docker tag portfolio-frontend:latest "$DOCKER_USERNAME/portfolio-frontend:$VERSION"
docker tag portfolio-frontend:latest "$DOCKER_USERNAME/portfolio-frontend:$DATE_TAG"
Print-Success "Frontend taggé (latest, $VERSION, $DATE_TAG)"

# 7. Push Backend
Print-Step "Push Backend vers Docker Hub..."
docker push "$DOCKER_USERNAME/portfolio-backend:latest"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Backend:latest"; exit 1 }
docker push "$DOCKER_USERNAME/portfolio-backend:$VERSION"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Backend:$VERSION"; exit 1 }
docker push "$DOCKER_USERNAME/portfolio-backend:$DATE_TAG"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Backend:$DATE_TAG"; exit 1 }
Print-Success "Backend poussé vers Docker Hub"

# 8. Push Frontend
Print-Step "Push Frontend vers Docker Hub..."
docker push "$DOCKER_USERNAME/portfolio-frontend:latest"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Frontend:latest"; exit 1 }
docker push "$DOCKER_USERNAME/portfolio-frontend:$VERSION"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Frontend:$VERSION"; exit 1 }
docker push "$DOCKER_USERNAME/portfolio-frontend:$DATE_TAG"
if ($LASTEXITCODE -ne 0) { Print-Error "Échec du push Frontend:$DATE_TAG"; exit 1 }
Print-Success "Frontend poussé vers Docker Hub"

# 9. Résumé
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ Déploiement Réussi !             ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Images disponibles sur Docker Hub:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend:" -ForegroundColor Yellow
Write-Host "  • $DOCKER_USERNAME/portfolio-backend:latest"
Write-Host "  • $DOCKER_USERNAME/portfolio-backend:$VERSION"
Write-Host "  • $DOCKER_USERNAME/portfolio-backend:$DATE_TAG"
Write-Host ""
Write-Host "Frontend:" -ForegroundColor Yellow
Write-Host "  • $DOCKER_USERNAME/portfolio-frontend:latest"
Write-Host "  • $DOCKER_USERNAME/portfolio-frontend:$VERSION"
Write-Host "  • $DOCKER_USERNAME/portfolio-frontend:$DATE_TAG"
Write-Host ""
Write-Host "🌐 Voir sur: https://hub.docker.com/u/$DOCKER_USERNAME" -ForegroundColor Cyan
Write-Host ""

# 10. Afficher les tailles des images
Print-Step "Tailles des images:"
docker images | Select-String -Pattern "REPOSITORY|$DOCKER_USERNAME/portfolio"

Write-Host ""
Print-Success "Script terminé avec succès!"
Write-Host ""
