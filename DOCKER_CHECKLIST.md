# CHECKLIST DOCKER - PORTFOLIO

## ✅ Fichiers créés

### Racine du projet
- [x] `docker-compose.yml` - Orchestration des 3 services
- [x] `mongo-init.js` - Initialisation de MongoDB
- [x] `DOCKER_README.md` - Documentation complète
- [x] `GUIDE_VIDEO_DOCKER.md` - Script pour la vidéo
- [x] `DOCKER_COMMANDS.md` - Aide-mémoire des commandes
- [x] `DOCKER_CHECKLIST.md` - Ce fichier

### Express.js (Backend)
- [x] `express-js/Dockerfile` - Image Docker pour Express
- [x] `express-js/.dockerignore` - Fichiers à exclure

### React (Frontend)
- [x] `react-js/Dockerfile` - Image Docker multi-stage
- [x] `react-js/nginx.conf` - Configuration Nginx
- [x] `react-js/.dockerignore` - Fichiers à exclure
- [x] `react-js/.env.production` - Variables d'environnement

---

## 🔧 Modifications du code

### Backend (Express.js)
- [x] Aucune modification nécessaire
- [x] `.env` déjà configuré pour MongoDB Atlas
- [x] CORS déjà configuré

### Frontend (React)
- [x] `projectService.js` - URL API dynamique avec `process.env.REACT_APP_API_URL`

---

## 🚀 Tests avant la vidéo

### 1. Prérequis
- [ ] Docker Desktop installé et démarré
- [ ] Tous les serveurs locaux arrêtés (React, Express, MongoDB)
- [ ] Terminal propre

### 2. Construction des images
```bash
cd C:\laragon\www\projet_fil_rouge
docker-compose build
```
- [ ] Build réussi sans erreur
- [ ] 3 images créées (mongodb, backend, frontend)

### 3. Démarrage des services
```bash
docker-compose up -d
```
- [ ] 3 conteneurs démarrés
- [ ] Statut "Up (healthy)" pour tous les services

### 4. Vérification MongoDB
```bash
docker exec -it portfolio-mongodb mongosh -u admin -p admin123 --authenticationDatabase admin
use portfolio
db.projects.find().pretty()
exit
```
- [ ] Connexion réussie
- [ ] 2 projets présents dans la base

### 5. Test API Backend
```bash
curl http://localhost:5000
curl http://localhost:5000/api/projects
```
- [ ] Réponse JSON reçue
- [ ] 2 projets retournés

### 6. Test Frontend React
- [ ] http://localhost:3000 accessible
- [ ] Page "Projets" affiche les 2 projets
- [ ] Ajout d'un projet fonctionne
- [ ] Modification d'un projet fonctionne
- [ ] Suppression d'un projet fonctionne

### 7. Logs
```bash
docker-compose logs
```
- [ ] Pas d'erreur dans les logs
- [ ] Connexion MongoDB visible
- [ ] Requêtes HTTP visibles

### 8. Arrêt
```bash
docker-compose down
```
- [ ] Tous les conteneurs arrêtés
- [ ] Pas d'erreur

---

## 🎬 Checklist pour la vidéo

### Avant l'enregistrement
- [ ] Logiciel d'enregistrement configuré (OBS, Camtasia, etc.)
- [ ] Microphone testé
- [ ] Résolution : 1920x1080
- [ ] FPS : 30 ou 60
- [ ] Terminal en plein écran
- [ ] Police du terminal lisible (taille 14-16)
- [ ] Navigateur avec onglets fermés
- [ ] Docker Desktop démarré
- [ ] Tous les conteneurs arrêtés

### Pendant l'enregistrement
- [ ] Parler clairement et lentement
- [ ] Expliquer chaque commande avant de l'exécuter
- [ ] Montrer les résultats dans le terminal
- [ ] Montrer l'application dans le navigateur
- [ ] Zoomer si nécessaire

### Après l'enregistrement
- [ ] Vérifier la qualité audio
- [ ] Vérifier la qualité vidéo
- [ ] Ajouter des titres pour chaque partie
- [ ] Ajouter une intro et une outro
- [ ] Exporter en HD (1080p)

---

## 📋 Structure de la vidéo

| Partie | Durée | Contenu | Checklist |
|--------|-------|---------|-----------|
| 1. Introduction | 2 min | Présentation | [ ] |
| 2. Fichiers Docker | 3 min | Explication | [ ] |
| 3. Build | 5 min | Construction | [ ] |
| 4. Démarrage | 3 min | Lancement | [ ] |
| 5. MongoDB | 2 min | Vérification | [ ] |
| 6. API | 2 min | Test | [ ] |
| 7. Frontend | 3 min | Test | [ ] |
| 8. Inspection | 2 min | Analyse | [ ] |
| 9. Logs | 2 min | Consultation | [ ] |
| 10. Arrêt | 2 min | Nettoyage | [ ] |
| 11. Redémarrage | 1 min | Relance | [ ] |
| 12. Conclusion | 1 min | Récapitulatif | [ ] |

**Durée totale : ~28 minutes**

---

## 🎯 Points clés à mentionner

### Architecture
- [ ] 3 services : MongoDB, Express, React
- [ ] 1 réseau : portfolio-network
- [ ] 1 volume : mongodb_data
- [ ] 3 ports : 27017, 5000, 3000

### Avantages Docker
- [ ] Portabilité
- [ ] Isolation
- [ ] Reproductibilité
- [ ] Facilité de déploiement
- [ ] Gestion des dépendances

### Bonnes pratiques
- [ ] Multi-stage build (React)
- [ ] Healthchecks
- [ ] Variables d'environnement
- [ ] .dockerignore
- [ ] Volumes pour la persistance

---

## 🐛 Problèmes courants et solutions

### Build échoue
- [ ] Vérifier la connexion internet
- [ ] Vérifier les Dockerfiles
- [ ] Nettoyer le cache : `docker-compose build --no-cache`

### Conteneurs ne démarrent pas
- [ ] Vérifier les logs : `docker-compose logs`
- [ ] Vérifier les ports disponibles
- [ ] Redémarrer Docker Desktop

### MongoDB ne se connecte pas
- [ ] Attendre le healthcheck (30 secondes)
- [ ] Vérifier les credentials
- [ ] Redémarrer MongoDB : `docker-compose restart mongodb`

### Frontend ne charge pas
- [ ] Vérifier le build React
- [ ] Vérifier nginx.conf
- [ ] Reconstruire : `docker-compose build frontend`

### API ne répond pas
- [ ] Vérifier la connexion MongoDB
- [ ] Vérifier les variables d'environnement
- [ ] Voir les logs : `docker-compose logs backend`

---

## 📊 Métriques de succès

### Performance
- [ ] Build < 10 minutes
- [ ] Démarrage < 1 minute
- [ ] Frontend charge < 3 secondes
- [ ] API répond < 500ms

### Qualité
- [ ] Aucune erreur dans les logs
- [ ] Tous les healthchecks OK
- [ ] Toutes les fonctionnalités testées
- [ ] Documentation complète

---

## 🎓 Ressources

### Documentation
- [ ] DOCKER_README.md lu
- [ ] GUIDE_VIDEO_DOCKER.md lu
- [ ] DOCKER_COMMANDS.md consulté

### Liens utiles
- [ ] Docker Docs : https://docs.docker.com/
- [ ] Docker Compose : https://docs.docker.com/compose/
- [ ] Docker Hub : https://hub.docker.com/

---

## ✨ Après la vidéo

### Nettoyage
- [ ] Arrêter les conteneurs : `docker-compose down`
- [ ] Supprimer les volumes : `docker-compose down -v`
- [ ] Nettoyer Docker : `docker system prune -a`

### Partage
- [ ] Uploader la vidéo
- [ ] Ajouter une description
- [ ] Ajouter des tags
- [ ] Partager le lien

### Amélioration
- [ ] Lire les commentaires
- [ ] Répondre aux questions
- [ ] Mettre à jour la documentation si nécessaire

---

**Auteur :** Kiro AI  
**Date :** 28 Avril 2026  
**Version :** 1.0

**Bonne chance pour la vidéo ! 🎬**
