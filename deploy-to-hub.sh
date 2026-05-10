#!/bin/bash

# ============================================
# Script de Déploiement vers Docker Hub
# ============================================

# Configuration
DOCKER_USERNAME="dembouz7"
VERSION="v1.0.0"
DATE_TAG=$(date +%Y%m%d)

# Vous pouvez modifier ces valeurs :
# - DOCKER_USERNAME : votre username Docker Hub
# - VERSION : version de votre application (ex: v1.0.0, v1.1.0, v2.0.0)
# - DATE_TAG : tag avec la date (généré automatiquement)

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Fonction pour vérifier les erreurs
check_error() {
    if [ $? -ne 0 ]; then
        print_error "$1"
        exit 1
    fi
}

# Banner
echo ""
echo "╔════════════════════════════════════════╗"
echo "║   🐳 Déploiement vers Docker Hub      ║"
echo "╔════════════════════════════════════════╗"
echo ""

# Vérifier si le username est configuré
if [ "$DOCKER_USERNAME" = "dembouz7" ]; then
    print_warning "Username Docker Hub configuré : $DOCKER_USERNAME"
    echo "Pour changer le username, modifiez la variable DOCKER_USERNAME dans le script"
    echo ""
fi

# 1. Vérifier Docker
print_step "Vérification de Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "Docker n'est pas démarré ou n'est pas installé"
    exit 1
fi
print_success "Docker est opérationnel"

# 2. Connexion Docker Hub
print_step "Connexion à Docker Hub..."
docker login
check_error "Échec de la connexion à Docker Hub"
print_success "Connecté à Docker Hub"

# 3. Build Backend
print_step "Build de l'image Backend..."
cd express-js || exit 1
docker build -t portfolio-backend:latest .
check_error "Échec du build Backend"
cd ..
print_success "Backend buildé avec succès"

# 4. Build Frontend
print_step "Build de l'image Frontend..."
cd react-js || exit 1
docker build -t portfolio-frontend:latest .
check_error "Échec du build Frontend"
cd ..
print_success "Frontend buildé avec succès"

# 5. Tag Backend
print_step "Tag de l'image Backend..."
docker tag portfolio-backend:latest $DOCKER_USERNAME/portfolio-backend:latest
docker tag portfolio-backend:latest $DOCKER_USERNAME/portfolio-backend:$VERSION
docker tag portfolio-backend:latest $DOCKER_USERNAME/portfolio-backend:$DATE_TAG
print_success "Backend taggé (latest, $VERSION, $DATE_TAG)"

# 6. Tag Frontend
print_step "Tag de l'image Frontend..."
docker tag portfolio-frontend:latest $DOCKER_USERNAME/portfolio-frontend:latest
docker tag portfolio-frontend:latest $DOCKER_USERNAME/portfolio-frontend:$VERSION
docker tag portfolio-frontend:latest $DOCKER_USERNAME/portfolio-frontend:$DATE_TAG
print_success "Frontend taggé (latest, $VERSION, $DATE_TAG)"

# 7. Push Backend
print_step "Push Backend vers Docker Hub..."
docker push $DOCKER_USERNAME/portfolio-backend:latest
check_error "Échec du push Backend:latest"
docker push $DOCKER_USERNAME/portfolio-backend:$VERSION
check_error "Échec du push Backend:$VERSION"
docker push $DOCKER_USERNAME/portfolio-backend:$DATE_TAG
check_error "Échec du push Backend:$DATE_TAG"
print_success "Backend poussé vers Docker Hub"

# 8. Push Frontend
print_step "Push Frontend vers Docker Hub..."
docker push $DOCKER_USERNAME/portfolio-frontend:latest
check_error "Échec du push Frontend:latest"
docker push $DOCKER_USERNAME/portfolio-frontend:$VERSION
check_error "Échec du push Frontend:$VERSION"
docker push $DOCKER_USERNAME/portfolio-frontend:$DATE_TAG
check_error "Échec du push Frontend:$DATE_TAG"
print_success "Frontend poussé vers Docker Hub"

# 9. Résumé
echo ""
echo "╔════════════════════════════════════════╗"
echo "║   ✅ Déploiement Réussi !             ║"
echo "╔════════════════════════════════════════╗"
echo ""
echo "📦 Images disponibles sur Docker Hub:"
echo ""
echo "Backend:"
echo "  • $DOCKER_USERNAME/portfolio-backend:latest"
echo "  • $DOCKER_USERNAME/portfolio-backend:$VERSION"
echo "  • $DOCKER_USERNAME/portfolio-backend:$DATE_TAG"
echo ""
echo "Frontend:"
echo "  • $DOCKER_USERNAME/portfolio-frontend:latest"
echo "  • $DOCKER_USERNAME/portfolio-frontend:$VERSION"
echo "  • $DOCKER_USERNAME/portfolio-frontend:$DATE_TAG"
echo ""
echo "🌐 Voir sur: https://hub.docker.com/u/$DOCKER_USERNAME"
echo ""

# 10. Afficher les tailles des images
print_step "Tailles des images:"
docker images | grep -E "REPOSITORY|$DOCKER_USERNAME/portfolio"

echo ""
print_success "Script terminé avec succès!"
echo ""
