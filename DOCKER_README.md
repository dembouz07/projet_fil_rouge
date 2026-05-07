# DOCKER - PORTFOLIO REACT + EXPRESS + MONGODB

## 🐳 Architecture Docker

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                            │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   MongoDB    │  │   Express    │  │    React     │     │
│  │   Port 27017 │  │   Port 5000  │  │   Port 3000  │     │
│  │              │  │              │  │   (Nginx)    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┴──────────────────┘             │
│                   portfolio-network                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Prérequis

- **Docker Desktop** installé : https://www.docker.com/products/docker-desktop
- **Docker Compose** (inclus avec Docker Desktop)
- **Git** (optionnel)

---

## 🚀 Démarrage rapide

### 1. Cloner le projet (si nécessaire)
```bash
git clone <url-du-repo>
cd projet_fil_rouge
```

### 2. Construire les images Docker
```bash
docker-compose build
```

### 3. Démarrer tous les services
```bash
docker-compose up -d
```

### 4. Vérifier que tout fonctionne
```bash
docker-compose ps
```

Vous devriez voir 3 services avec le statut "Up (healthy)".

### 5. Accéder à l'application

- **Frontend React** : http://localhost:3000
- **Backend API** : http://localhost:5000
- **MongoDB** : localhost:27017

---

## 📦 Services Docker

### MongoDB
- **Image** : mongo:7.0
- **Port** : 27017
- **Credentials** :
  - Username: `admin`
  - Password: `admin123`
- **Base de données** : `portfolio`
- **Volume** : `mongodb_data` (persistance des données)

### Backend (Express.js)
- **Build** : express-js/Dockerfile
- **Port** : 5000
- **Variables d'environnement** :
  - `NODE_ENV=production`
  - `PORT=5000`
  - `MONGODB_URI=mongodb://admin:admin123@mongodb:27017/portfolio?authSource=admin`
  - `CORS_ORIGIN=http://localhost:3000`

### Frontend (React + Nginx)
- **Build** : react-js/Dockerfile (multi-stage)
- **Port** : 3000 (mappé sur le port 80 du conteneur)
- **Serveur** : Nginx
- **Configuration** : react-js/nginx.conf

---

## 🛠️ Commandes utiles

### Démarrage et arrêt

```bash
# Démarrer tous les services
docker-compose up -d

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (données)
docker-compose down -v

# Redémarrer un service spécifique
docker-compose restart backend
```

### Logs

```bash
# Voir tous les logs
docker-compose logs

# Suivre les logs en temps réel
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongodb
```

### Inspection

```bash
# Lister les conteneurs
docker-compose ps

# Statistiques des conteneurs
docker stats

# Inspecter un conteneur
docker inspect portfolio-backend

# Voir les réseaux
docker network ls

# Voir les volumes
docker volume ls
```

### Accès aux conteneurs

```bash
# Se connecter au conteneur backend
docker exec -it portfolio-backend sh

# Se connecter à MongoDB
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Se connecter au conteneur frontend
docker exec -it portfolio-frontend sh
```

### Reconstruction

```bash
# Reconstruire les images
docker-compose build

# Reconstruire sans cache
docker-compose build --no-cache

# Reconstruire et redémarrer
docker-compose up -d --build
```

---

## 🗄️ Gestion de MongoDB

### Se connecter à MongoDB

```bash
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
```

### Commandes MongoDB utiles

```javascript
// Utiliser la base de données portfolio
use portfolio

// Lister les collections
show collections

// Voir tous les projets
db.projects.find().pretty()

// Compter les projets
db.projects.countDocuments()

// Ajouter un projet
db.projects.insertOne({
  title: "Nouveau Projet",
  description: "Description du projet",
  technologies: ["React", "Node.js"],
  image: "https://placehold.co/400x200",
  github: "https://github.com/user/repo",
  demo: "https://demo.com",
  createdAt: new Date(),
  updatedAt: new Date()
})

// Supprimer tous les projets
db.projects.deleteMany({})

// Quitter
exit
```

---

## 🔧 Configuration

### Variables d'environnement

Les variables d'environnement sont définies dans `docker-compose.yml`.

Pour modifier :
1. Éditer `docker-compose.yml`
2. Redémarrer les services : `docker-compose up -d`

### Ports

Pour changer les ports, modifier dans `docker-compose.yml` :

```yaml
services:
  frontend:
    ports:
      - "8080:80"  # Changer 3000 en 8080
```

---

## 🐛 Dépannage

### Les conteneurs ne démarrent pas

```bash
# Voir les logs d'erreur
docker-compose logs

# Vérifier l'état des services
docker-compose ps

# Redémarrer tous les services
docker-compose restart
```

### MongoDB ne se connecte pas

```bash
# Vérifier que MongoDB est en cours d'exécution
docker-compose ps mongodb

# Voir les logs MongoDB
docker-compose logs mongodb

# Redémarrer MongoDB
docker-compose restart mongodb
```

### Le frontend ne charge pas

```bash
# Vérifier les logs Nginx
docker-compose logs frontend

# Reconstruire l'image frontend
docker-compose build frontend
docker-compose up -d frontend
```

### Le backend ne répond pas

```bash
# Vérifier les logs Express
docker-compose logs backend

# Vérifier la connexion MongoDB
docker exec -it portfolio-backend sh
wget -O- http://localhost:5000
```

### Erreur "port already in use"

```bash
# Trouver le processus qui utilise le port
netstat -ano | findstr :3000
netstat -ano | findstr :5000
netstat -ano | findstr :27017

# Arrêter le processus ou changer le port dans docker-compose.yml
```

### Nettoyer Docker

```bash
# Supprimer tous les conteneurs arrêtés
docker container prune

# Supprimer toutes les images inutilisées
docker image prune -a

# Supprimer tous les volumes inutilisés
docker volume prune

# Nettoyage complet
docker system prune -a --volumes
```

---

## 📊 Monitoring

### Voir l'utilisation des ressources

```bash
# Statistiques en temps réel
docker stats

# Statistiques d'un conteneur spécifique
docker stats portfolio-backend
```

### Healthchecks

Tous les services ont des healthchecks configurés :

```bash
# Vérifier l'état de santé
docker-compose ps

# Inspecter le healthcheck
docker inspect --format='{{json .State.Health}}' portfolio-backend
```

---

## 🚀 Déploiement en production

### Sur un serveur distant

```bash
# 1. Copier les fichiers sur le serveur
scp -r . user@server:/path/to/project

# 2. Se connecter au serveur
ssh user@server

# 3. Démarrer les services
cd /path/to/project
docker-compose up -d
```

### Avec Docker Swarm

```bash
# Initialiser Swarm
docker swarm init

# Déployer la stack
docker stack deploy -c docker-compose.yml portfolio

# Voir les services
docker stack services portfolio
```

### Avec Kubernetes

Convertir docker-compose.yml en manifests Kubernetes :

```bash
# Installer kompose
curl -L https://github.com/kubernetes/kompose/releases/download/v1.28.0/kompose-windows-amd64.exe -o kompose.exe

# Convertir
kompose convert -f docker-compose.yml
```

---

## 📝 Fichiers Docker

### Structure

```
projet_fil_rouge/
├── docker-compose.yml          # Orchestration des services
├── mongo-init.js               # Initialisation MongoDB
├── express-js/
│   ├── Dockerfile              # Image Express
│   └── .dockerignore           # Fichiers à exclure
└── react-js/
    ├── Dockerfile              # Image React + Nginx
    ├── nginx.conf              # Configuration Nginx
    ├── .dockerignore           # Fichiers à exclure
    └── .env.production         # Variables d'environnement
```

---

## 🔐 Sécurité

### Bonnes pratiques

1. **Ne pas commiter les secrets** : Utiliser des variables d'environnement
2. **Changer les mots de passe** : Modifier `admin123` en production
3. **Utiliser HTTPS** : Configurer un reverse proxy (Nginx, Traefik)
4. **Limiter les ports exposés** : Exposer uniquement le frontend en production
5. **Scanner les images** : Utiliser `docker scan` pour détecter les vulnérabilités

### Exemple de configuration sécurisée

```yaml
services:
  mongodb:
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    # Ne pas exposer le port en production
    # ports:
    #   - "27017:27017"
```

---

## 📚 Ressources

- **Documentation Docker** : https://docs.docker.com/
- **Documentation Docker Compose** : https://docs.docker.com/compose/
- **Docker Hub** : https://hub.docker.com/
- **Best Practices** : https://docs.docker.com/develop/dev-best-practices/

---

## 🎯 Checklist de déploiement

- [ ] Docker Desktop installé
- [ ] Images construites : `docker-compose build`
- [ ] Services démarrés : `docker-compose up -d`
- [ ] Healthchecks OK : `docker-compose ps`
- [ ] Frontend accessible : http://localhost:3000
- [ ] Backend accessible : http://localhost:5000
- [ ] MongoDB accessible : localhost:27017
- [ ] Données initialisées : 2 projets dans MongoDB
- [ ] Tests fonctionnels : Ajouter/Modifier/Supprimer un projet

---

**Auteur :** Kiro AI  
**Date :** 28 Avril 2026  
**Version :** 1.0

**Bon déploiement ! 🚀**
