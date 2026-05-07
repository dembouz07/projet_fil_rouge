# GUIDE COMPLET - VIDÉO DÉMONSTRATION DOCKER

## 🎬 Préparation avant l'enregistrement

### 1. Vérifier les prérequis
```bash
# Vérifier Docker
docker --version

# Vérifier Docker Compose
docker-compose --version

# Nettoyer Docker (optionnel)
docker system prune -a --volumes
```

### 2. Préparer l'environnement
- Fermer tous les terminaux
- Arrêter tous les serveurs locaux (React, Express, MongoDB)
- Ouvrir un terminal propre
- Préparer un logiciel d'enregistrement (OBS Studio, Camtasia, etc.)

---

## 🎥 SCRIPT DE LA VIDÉO (15-20 minutes)

### PARTIE 1 : Introduction (2 minutes)

**À dire :**
> "Bonjour ! Aujourd'hui, je vais vous montrer comment dockeriser une application complète avec React, Express.js et MongoDB. Nous allons créer des conteneurs Docker pour chaque service et les orchestrer avec Docker Compose."

**À montrer :**
- Structure du projet dans l'explorateur de fichiers
- Les 3 dossiers : express-js, react-js, et les fichiers Docker

---

### PARTIE 2 : Présentation des fichiers Docker (3 minutes)

**À dire :**
> "Commençons par examiner les fichiers Docker que nous avons créés."

**Commandes à exécuter :**
```bash
# Se placer dans le dossier du projet
cd C:\laragon\www\projet_fil_rouge

# Lister les fichiers Docker
ls -la | grep -i docker
```

**À montrer :**
1. **docker-compose.yml** (racine)
   - Ouvrir le fichier
   - Expliquer les 3 services : mongodb, backend, frontend
   - Montrer les ports : 27017, 5000, 3000
   - Expliquer les volumes et networks

2. **express-js/Dockerfile**
   - Ouvrir le fichier
   - Expliquer les étapes : FROM, WORKDIR, COPY, RUN, EXPOSE, CMD

3. **react-js/Dockerfile**
   - Ouvrir le fichier
   - Expliquer le multi-stage build (build + nginx)

4. **mongo-init.js**
   - Ouvrir le fichier
   - Expliquer l'initialisation de la base de données

---

### PARTIE 3 : Construction des images Docker (5 minutes)

**À dire :**
> "Maintenant, construisons les images Docker pour nos services."

**Commandes à exécuter :**
```bash
# Construire toutes les images
docker-compose build

# Vérifier les images créées
docker images
```

**À montrer :**
- Le processus de build dans le terminal
- Les étapes de construction (Downloading, Extracting, Building)
- Les images créées avec leurs tailles

**Temps estimé :** 3-5 minutes (selon la connexion internet)

---

### PARTIE 4 : Démarrage des conteneurs (3 minutes)

**À dire :**
> "Les images sont prêtes. Démarrons maintenant tous les conteneurs avec Docker Compose."

**Commandes à exécuter :**
```bash
# Démarrer tous les services
docker-compose up -d

# Vérifier que les conteneurs sont en cours d'exécution
docker-compose ps

# Voir les logs en temps réel
docker-compose logs -f
```

**À montrer :**
- Les conteneurs qui démarrent
- Le statut "healthy" pour chaque service
- Les logs de MongoDB, Express et React

**Attendre que tous les services soient "healthy" (environ 30 secondes)**

---

### PARTIE 5 : Vérification de MongoDB (2 minutes)

**À dire :**
> "Vérifions que MongoDB est bien initialisé avec nos données de démonstration."

**Commandes à exécuter :**
```bash
# Se connecter au conteneur MongoDB
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Dans le shell MongoDB
use portfolio
db.projects.find().pretty()
exit
```

**À montrer :**
- La connexion à MongoDB
- Les 2 projets insérés automatiquement
- La structure des documents

---

### PARTIE 6 : Test de l'API Backend (2 minutes)

**À dire :**
> "Testons maintenant notre API Express.js."

**Commandes à exécuter :**
```bash
# Tester l'endpoint racine
curl http://localhost:5000

# Tester l'endpoint des projets
curl http://localhost:5000/api/projects
```

**Ou dans le navigateur :**
- Ouvrir http://localhost:5000
- Ouvrir http://localhost:5000/api/projects

**À montrer :**
- La réponse JSON de l'API
- Les 2 projets retournés
- Le format de la réponse avec success, count, data

---

### PARTIE 7 : Test du Frontend React (3 minutes)

**À dire :**
> "Maintenant, testons notre application React qui tourne dans un conteneur Nginx."

**Dans le navigateur :**
1. Ouvrir http://localhost:3000
2. Naviguer vers la page "Projets"
3. Montrer les 2 projets affichés
4. Cliquer sur "Voir" pour voir les détails
5. Tester "Ajouter un projet"
6. Remplir le formulaire et soumettre
7. Vérifier que le nouveau projet apparaît

**À montrer :**
- L'interface React qui fonctionne
- Les projets chargés depuis MongoDB
- L'ajout d'un nouveau projet
- La communication entre React, Express et MongoDB

---

### PARTIE 8 : Inspection des conteneurs (2 minutes)

**À dire :**
> "Regardons de plus près nos conteneurs Docker."

**Commandes à exécuter :**
```bash
# Lister tous les conteneurs
docker ps

# Voir les statistiques des conteneurs
docker stats --no-stream

# Inspecter le réseau
docker network inspect projet_fil_rouge_portfolio-network

# Voir les volumes
docker volume ls
```

**À montrer :**
- Les 3 conteneurs en cours d'exécution
- L'utilisation CPU et mémoire
- Le réseau Docker qui connecte les services
- Le volume MongoDB pour la persistance des données

---

### PARTIE 9 : Logs et débogage (2 minutes)

**À dire :**
> "Voyons comment consulter les logs de nos services."

**Commandes à exécuter :**
```bash
# Logs du backend
docker-compose logs backend

# Logs du frontend
docker-compose logs frontend

# Logs de MongoDB
docker-compose logs mongodb

# Suivre les logs en temps réel
docker-compose logs -f backend
```

**À montrer :**
- Les logs de connexion MongoDB
- Les requêtes HTTP dans Express
- Les logs Nginx

---

### PARTIE 10 : Arrêt et nettoyage (2 minutes)

**À dire :**
> "Pour terminer, voyons comment arrêter et nettoyer nos conteneurs."

**Commandes à exécuter :**
```bash
# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (données)
docker-compose down -v

# Vérifier que tout est arrêté
docker ps -a

# Nettoyer les images inutilisées (optionnel)
docker system prune -a
```

**À montrer :**
- Les conteneurs qui s'arrêtent
- La suppression des volumes
- Le système Docker nettoyé

---

### PARTIE 11 : Redémarrage rapide (1 minute)

**À dire :**
> "Pour redémarrer l'application, il suffit d'une seule commande."

**Commandes à exécuter :**
```bash
# Redémarrer tous les services
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

**À montrer :**
- Le démarrage rapide (images déjà construites)
- L'application qui fonctionne à nouveau

---

### PARTIE 12 : Conclusion (1 minute)

**À dire :**
> "Voilà ! Nous avons dockerisé avec succès notre application complète. Les avantages de Docker sont nombreux : portabilité, isolation, facilité de déploiement, et reproductibilité. Merci d'avoir suivi cette démonstration !"

**À montrer :**
- Récapitulatif des 3 services
- Les URLs : localhost:3000 (React), localhost:5000 (Express), localhost:27017 (MongoDB)

---

## 📋 CHECKLIST AVANT L'ENREGISTREMENT

### Préparation technique
- [ ] Docker Desktop installé et démarré
- [ ] Tous les serveurs locaux arrêtés
- [ ] Terminal propre et prêt
- [ ] Navigateur avec onglets fermés
- [ ] Logiciel d'enregistrement configuré

### Préparation des fichiers
- [ ] docker-compose.yml créé
- [ ] express-js/Dockerfile créé
- [ ] react-js/Dockerfile créé
- [ ] react-js/nginx.conf créé
- [ ] mongo-init.js créé
- [ ] .dockerignore créés

### Test préalable
- [ ] `docker-compose build` fonctionne
- [ ] `docker-compose up -d` fonctionne
- [ ] http://localhost:3000 accessible
- [ ] http://localhost:5000 accessible
- [ ] MongoDB accessible

---

## 🎬 COMMANDES COMPLÈTES POUR LA VIDÉO

```bash
# ============================================
# PARTIE 1 : PRÉPARATION
# ============================================

cd C:\laragon\www\projet_fil_rouge
ls -la

# ============================================
# PARTIE 2 : CONSTRUCTION DES IMAGES
# ============================================

docker-compose build
docker images

# ============================================
# PARTIE 3 : DÉMARRAGE DES SERVICES
# ============================================

docker-compose up -d
docker-compose ps
docker-compose logs -f

# Attendre que tous les services soient "healthy"
# Ctrl+C pour arrêter les logs

# ============================================
# PARTIE 4 : VÉRIFICATION MONGODB
# ============================================

docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Dans MongoDB shell :
use portfolio
db.projects.find().pretty()
exit

# ============================================
# PARTIE 5 : TEST API BACKEND
# ============================================

curl http://localhost:5000
curl http://localhost:5000/api/projects

# Ou ouvrir dans le navigateur :
# http://localhost:5000
# http://localhost:5000/api/projects

# ============================================
# PARTIE 6 : TEST FRONTEND REACT
# ============================================

# Ouvrir dans le navigateur :
# http://localhost:3000
# Naviguer vers "Projets"
# Tester l'ajout d'un projet

# ============================================
# PARTIE 7 : INSPECTION DES CONTENEURS
# ============================================

docker ps
docker stats --no-stream
docker network inspect projet_fil_rouge_portfolio-network
docker volume ls

# ============================================
# PARTIE 8 : LOGS
# ============================================

docker-compose logs backend
docker-compose logs frontend
docker-compose logs mongodb
docker-compose logs -f backend

# ============================================
# PARTIE 9 : ARRÊT ET NETTOYAGE
# ============================================

docker-compose down
docker-compose ps

# ============================================
# PARTIE 10 : REDÉMARRAGE
# ============================================

docker-compose up -d
docker-compose ps
```

---

## 🎯 POINTS CLÉS À MENTIONNER

### Avantages de Docker
1. **Portabilité** : Fonctionne partout (Windows, Mac, Linux)
2. **Isolation** : Chaque service dans son propre conteneur
3. **Reproductibilité** : Même environnement pour tous
4. **Facilité de déploiement** : Une commande pour tout démarrer
5. **Gestion des dépendances** : Tout est inclus dans l'image

### Architecture
1. **3 services** : MongoDB, Express, React
2. **1 réseau** : portfolio-network (communication entre services)
3. **1 volume** : mongodb_data (persistance des données)
4. **3 ports** : 27017 (MongoDB), 5000 (Express), 3000 (React)

### Bonnes pratiques
1. **Multi-stage build** pour React (réduction de la taille)
2. **Healthchecks** pour vérifier l'état des services
3. **Variables d'environnement** pour la configuration
4. **.dockerignore** pour exclure les fichiers inutiles
5. **Volumes** pour la persistance des données

---

## 📊 DURÉE ESTIMÉE PAR PARTIE

| Partie | Durée | Contenu |
|--------|-------|---------|
| Introduction | 2 min | Présentation du projet |
| Fichiers Docker | 3 min | Explication des Dockerfiles |
| Build des images | 5 min | Construction des images |
| Démarrage | 3 min | Lancement des conteneurs |
| MongoDB | 2 min | Vérification de la BDD |
| API Backend | 2 min | Test de l'API |
| Frontend React | 3 min | Test de l'interface |
| Inspection | 2 min | Analyse des conteneurs |
| Logs | 2 min | Consultation des logs |
| Arrêt | 2 min | Nettoyage |
| Redémarrage | 1 min | Relance rapide |
| Conclusion | 1 min | Récapitulatif |
| **TOTAL** | **28 min** | **Vidéo complète** |

---

## 🎤 CONSEILS POUR L'ENREGISTREMENT

### Audio
- Utiliser un bon microphone
- Parler clairement et lentement
- Éviter les bruits de fond

### Vidéo
- Résolution : 1920x1080 (Full HD)
- FPS : 30 ou 60
- Zoom sur le terminal si nécessaire

### Montage
- Ajouter des titres pour chaque partie
- Accélérer les parties longues (build)
- Ajouter de la musique de fond (optionnel)

---

## 🚀 COMMANDES DE DÉPLOIEMENT (BONUS)

### Déploiement sur un serveur distant

```bash
# Copier les fichiers sur le serveur
scp -r . user@server:/path/to/project

# Se connecter au serveur
ssh user@server

# Démarrer les services
cd /path/to/project
docker-compose up -d
```

### Mise à jour de l'application

```bash
# Reconstruire les images
docker-compose build

# Redémarrer les services
docker-compose up -d --force-recreate
```

---

**Auteur :** Kiro AI  
**Date :** 28 Avril 2026  
**Version :** 1.0

**Bon enregistrement ! 🎬**
