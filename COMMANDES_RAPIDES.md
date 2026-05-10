# 🚀 Commandes Docker Hub - Portfolio dembouz7

## ⚡ Quick Start (3 étapes)

### 1️⃣ Se connecter à Docker Hub
```bash
docker login
# Username: dembouz7
# Password: [votre mot de passe]
```

### 2️⃣ Build, Tag et Push (tout en une fois)
```bash
# Backend
docker build -t dembouz7/portfolio-backend:latest ./express-js && \
docker push dembouz7/portfolio-backend:latest

# Frontend
docker build -t dembouz7/portfolio-frontend:latest ./react-js && \
docker push dembouz7/portfolio-frontend:latest
```

### 3️⃣ Déployer depuis Docker Hub
```bash
docker-compose -f docker-compose.hub.yml up -d
```

---

## 📦 Versions Utilisées

| Composant | Image | Version |
|-----------|-------|---------|
| Backend | node | 20.18.1-alpine3.20 |
| Frontend | nginx | 1.27.3-alpine3.20 |
| Database | mongo | 7.0.15 |

**Utilisateurs non-root :**
- Backend : nodejs (UID 1001)
- Frontend : nginx-app (UID 1001)
- MongoDB : mongodb (UID 999)

---

## 📝 Commandes Essentielles

### Build Local
```bash
# Backend
docker build -t portfolio-backend:latest ./express-js

# Frontend
docker build -t portfolio-frontend:latest ./react-js

# Les deux avec docker-compose
docker-compose build
```

### Tag pour Docker Hub
```bash
# Backend
docker tag portfolio-backend:latest dembouz7/portfolio-backend:latest
docker tag portfolio-backend:latest dembouz7/portfolio-backend:v1.0.0

# Frontend
docker tag portfolio-frontend:latest dembouz7/portfolio-frontend:latest
docker tag portfolio-frontend:latest dembouz7/portfolio-frontend:v1.0.0
```

### Push vers Docker Hub
```bash
# Backend
docker push dembouz7/portfolio-backend:latest
docker push dembouz7/portfolio-backend:v1.0.0

# Frontend
docker push dembouz7/portfolio-frontend:latest
docker push dembouz7/portfolio-frontend:v1.0.0

# Push toutes les versions
docker push dembouz7/portfolio-backend --all-tags
docker push dembouz7/portfolio-frontend --all-tags
```

### Pull depuis Docker Hub
```bash
# Backend
docker pull dembouz7/portfolio-backend:latest

# Frontend
docker pull dembouz7/portfolio-frontend:latest

# Avec docker-compose
docker-compose -f docker-compose.hub.yml pull
```

---

## 🔄 Workflow Complet

### Développement → Production

```bash
# 1. Build local
docker-compose build

# 2. Test local
docker-compose up -d
docker-compose logs -f

# 3. Si OK, tag pour Docker Hub
docker tag portfolio-backend:latest dembouz7/portfolio-backend:latest
docker tag portfolio-frontend:latest dembouz7/portfolio-frontend:latest

# 4. Push vers Docker Hub
docker push dembouz7/portfolio-backend:latest
docker push dembouz7/portfolio-frontend:latest

# 5. Déployer en production
docker-compose -f docker-compose.hub.yml pull
docker-compose -f docker-compose.hub.yml up -d
```

---

## 🛠️ Gestion des Images

### Lister les images
```bash
# Toutes les images
docker images

# Filtrer par nom
docker images | grep portfolio
docker images | grep dembouz7

# Voir les tailles
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Supprimer des images
```bash
# Une image spécifique
docker rmi portfolio-backend:latest

# Plusieurs images
docker rmi portfolio-backend:latest portfolio-frontend:latest

# Toutes les images non utilisées
docker image prune -a

# Forcer la suppression
docker rmi -f portfolio-backend:latest
```

### Nettoyer Docker
```bash
# Supprimer les images non utilisées
docker image prune -a

# Supprimer tout (images, containers, volumes, networks)
docker system prune -a --volumes

# Voir l'espace utilisé
docker system df
```

---

## 🐳 Gestion des Containers

### Démarrer/Arrêter
```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer
docker-compose restart

# Arrêter et supprimer les volumes
docker-compose down -v
```

### Logs
```bash
# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f backend
docker-compose logs -f frontend

# Dernières 100 lignes
docker-compose logs --tail=100 backend
```

### Inspecter
```bash
# Voir les containers en cours
docker ps

# Voir tous les containers
docker ps -a

# Statistiques en temps réel
docker stats

# Inspecter un container
docker inspect portfolio-backend
```

### Entrer dans un container
```bash
# Backend
docker exec -it portfolio-backend sh

# Frontend
docker exec -it portfolio-frontend sh

# MongoDB
docker exec -it portfolio-mongodb mongosh
```

---

## 🔍 Debug et Troubleshooting

### Vérifier les logs d'erreur
```bash
# Backend
docker logs portfolio-backend --tail=50

# Frontend
docker logs portfolio-frontend --tail=50

# MongoDB
docker logs portfolio-mongodb --tail=50
```

### Tester une image
```bash
# Backend (port 5000)
docker run -p 5000:5000 dembouz7/portfolio-backend:latest

# Frontend (port 3000)
docker run -p 3000:80 dembouz7/portfolio-frontend:latest
```

### Vérifier la connexion réseau
```bash
# Lister les réseaux
docker network ls

# Inspecter un réseau
docker network inspect portfolio-network

# Tester la connexion entre containers
docker exec portfolio-backend ping mongodb
```

### Rebuild sans cache
```bash
# Un service
docker-compose build --no-cache backend

# Tous les services
docker-compose build --no-cache

# Avec docker build
docker build --no-cache -t portfolio-backend:latest ./express-js
```

---

## 📊 Monitoring

### Voir l'utilisation des ressources
```bash
# Statistiques en temps réel
docker stats

# Statistiques d'un container
docker stats portfolio-backend

# Espace disque
docker system df

# Détails de l'espace disque
docker system df -v
```

### Vérifier la santé
```bash
# Status des containers
docker-compose ps

# Inspecter la santé
docker inspect --format='{{.State.Health.Status}}' portfolio-backend
```

---

## 🔐 Sécurité

### Scanner les vulnérabilités
```bash
# Scanner une image
docker scan dembouz7/portfolio-backend:latest

# Scanner avec détails
docker scan --severity high dembouz7/portfolio-backend:latest
```

### Vérifier les secrets
```bash
# Ne jamais commit ces fichiers
.env
.env.local
.env.production
docker-compose.override.yml
```

---

## 🎯 Commandes One-Liner Utiles

### Build et Push en une commande
```bash
# Backend
docker build -t dembouz7/portfolio-backend:latest ./express-js && docker push dembouz7/portfolio-backend:latest

# Frontend
docker build -t dembouz7/portfolio-frontend:latest ./react-js && docker push dembouz7/portfolio-frontend:latest

# Les deux
docker build -t dembouz7/portfolio-backend:latest ./express-js && \
docker build -t dembouz7/portfolio-frontend:latest ./react-js && \
docker push dembouz7/portfolio-backend:latest && \
docker push dembouz7/portfolio-frontend:latest
```

### Pull et Deploy
```bash
docker-compose -f docker-compose.hub.yml pull && docker-compose -f docker-compose.hub.yml up -d
```

### Stop, Clean et Restart
```bash
docker-compose down && docker system prune -f && docker-compose up -d
```

### Rebuild et Restart
```bash
docker-compose down && docker-compose build --no-cache && docker-compose up -d
```

---

## 📦 Versions et Tags

### Créer plusieurs tags
```bash
# Backend avec version et date
VERSION="v1.0.0"
DATE=$(date +%Y%m%d)

docker tag portfolio-backend:latest dembouz7/portfolio-backend:latest
docker tag portfolio-backend:latest dembouz7/portfolio-backend:$VERSION
docker tag portfolio-backend:latest dembouz7/portfolio-backend:$DATE

# Push tous les tags
docker push dembouz7/portfolio-backend --all-tags
```

### Lister les tags sur Docker Hub
```bash
# Utiliser l'API Docker Hub
curl -s https://hub.docker.com/v2/repositories/dembouz7/portfolio-backend/tags/ | jq -r '.results[].name'
```

---

## 🌐 Déploiement Multi-Environnement

### Développement
```bash
docker-compose -f docker-compose.yml up -d
```

### Production (depuis Docker Hub)
```bash
docker-compose -f docker-compose.hub.yml up -d
```

### Staging
```bash
docker-compose -f docker-compose.staging.yml up -d
```

---

## 💡 Tips et Astuces

### Alias utiles (à ajouter dans .bashrc ou .zshrc)
```bash
# Alias Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcb='docker-compose build'
alias dcp='docker-compose pull'

# Alias nettoyage
alias dclean='docker system prune -a --volumes'
alias dimgclean='docker image prune -a'
```

### Variables d'environnement
```bash
# Définir le username Docker Hub
export DOCKER_USERNAME="dembouz7"

# Utiliser dans les commandes
docker tag portfolio-backend:latest $DOCKER_USERNAME/portfolio-backend:latest
docker push $DOCKER_USERNAME/portfolio-backend:latest
```

---

## 📱 Commandes PowerShell (Windows)

### Build et Push
```powershell
# Backend
docker build -t dembouz7/portfolio-backend:latest .\express-js
docker push dembouz7/portfolio-backend:latest

# Frontend
docker build -t dembouz7/portfolio-frontend:latest .\react-js
docker push dembouz7/portfolio-frontend:latest
```

### Variables
```powershell
$DOCKER_USERNAME = "dembouz7"
$VERSION = "v1.0.0"

docker tag portfolio-backend:latest "$DOCKER_USERNAME/portfolio-backend:$VERSION"
docker push "$DOCKER_USERNAME/portfolio-backend:$VERSION"
```

---

## ✅ Checklist Rapide

Avant de push vers Docker Hub :
- [ ] Code testé localement
- [ ] `docker-compose up -d` fonctionne
- [ ] Variables d'environnement configurées
- [ ] Connecté à Docker Hub (`docker login`)
- [ ] Images taggées correctement
- [ ] `.dockerignore` à jour

---

## 🆘 Commandes de Dépannage

### Problème de connexion Docker Hub
```bash
docker logout
docker login
```

### Problème d'espace disque
```bash
docker system prune -a --volumes
docker volume prune
```

### Container ne démarre pas
```bash
docker logs portfolio-backend
docker inspect portfolio-backend
docker-compose config
```

### Port déjà utilisé
```bash
# Trouver le processus
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # Linux/Mac

# Changer le port dans docker-compose.yml
ports:
  - "5001:5000"  # Au lieu de 5000:5000
```

---

**💡 Conseil :** Gardez ce fichier à portée de main pour référence rapide !
