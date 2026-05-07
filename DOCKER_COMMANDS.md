# COMMANDES DOCKER - AIDE-MÉMOIRE

## 🚀 Démarrage rapide

```bash
# Construction et démarrage
docker-compose up -d --build

# Vérification
docker-compose ps

# Accès
# Frontend: http://localhost:3000
# Backend: http://localhost:5000
# MongoDB: localhost:27017
```

---

## 📦 Gestion des services

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

---

## 🔍 Logs et monitoring

```bash
# Tous les logs
docker-compose logs -f

# Logs d'un service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb

# Statistiques
docker stats
```

---

## 🗄️ MongoDB

```bash
# Se connecter
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Commandes MongoDB
use portfolio
db.projects.find().pretty()
db.projects.countDocuments()
exit
```

---

## 🔧 Débogage

```bash
# Accéder au conteneur backend
docker exec -it portfolio-backend sh

# Accéder au conteneur frontend
docker exec -it portfolio-frontend sh

# Inspecter un conteneur
docker inspect portfolio-backend
```

---

## 🧹 Nettoyage

```bash
# Supprimer les conteneurs arrêtés
docker container prune

# Supprimer les images inutilisées
docker image prune -a

# Nettoyage complet
docker system prune -a --volumes
```

---

## 🔄 Mise à jour

```bash
# Reconstruire les images
docker-compose build --no-cache

# Redémarrer avec les nouvelles images
docker-compose up -d --force-recreate
```

---

## 📊 Inspection

```bash
# Lister les conteneurs
docker ps

# Lister les images
docker images

# Lister les réseaux
docker network ls

# Lister les volumes
docker volume ls
```

---

## 🎬 Pour la vidéo (ordre complet)

```bash
# 1. Construction
docker-compose build

# 2. Démarrage
docker-compose up -d

# 3. Vérification
docker-compose ps

# 4. Test MongoDB
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
use portfolio
db.projects.find().pretty()
exit

# 5. Test API
curl http://localhost:5000/api/projects

# 6. Test Frontend
# Ouvrir http://localhost:3000 dans le navigateur

# 7. Logs
docker-compose logs -f

# 8. Arrêt
docker-compose down
```

---

**Auteur :** Kiro AI  
**Date :** 28 Avril 2026
