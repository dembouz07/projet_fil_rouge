# Déploiement Kubernetes - Portfolio

Ce dossier contient tous les manifests Kubernetes nécessaires pour déployer l'application Portfolio.

## 📖 Documentation complète

**→ Pour le guide complet de A à Z, consultez : [`../README_KUBERNETES_COMPLET.md`](../README_KUBERNETES_COMPLET.md)**

Ce guide de 82 KB contient :
- Introduction et concepts Kubernetes
- Installation complète (Windows/Linux/Mac)
- Déploiement étape par étape
- Opérations avancées (Scaling, Rolling Updates)
- Monitoring et debugging
- Troubleshooting complet
- 300+ commandes kubectl
- Bonnes pratiques de production

## 📋 Prérequis

- **Kubernetes cluster** (Minikube, Docker Desktop, ou cluster cloud)
- **kubectl** installé et configuré
- **Ingress Controller** (NGINX recommandé)

## 🚀 Déploiement

### Via Jenkins CI/CD (Recommandé)

Le déploiement est **automatisé via Jenkins** :

1. **Accédez à Jenkins** : http://localhost:8080
2. **Sélectionnez le job** : `portfolio-cicd`
3. **Cliquez sur** "Build with Parameters"
4. **Choisissez** `DEPLOY_TARGET = kubernetes`
5. **Lancez** le build

Jenkins va automatiquement :
- ✅ Builder les images Docker
- ✅ Les pousser sur Docker Hub
- ✅ Déployer sur Kubernetes
- ✅ Effectuer un rolling update sans coupure
- ✅ Vérifier que tout fonctionne
- ✅ Vous envoyer un email de confirmation

### Déploiement manuel

### 1. Créer le namespace
```bash
kubectl apply -f namespace.yaml
```

### 2. Déployer MongoDB
```bash
kubectl apply -f mongodb-deployment.yaml
```

### 3. Déployer le Backend
```bash
kubectl apply -f backend-deployment.yaml
```

### 4. Déployer le Frontend
```bash
kubectl apply -f frontend-deployment.yaml
```

### 5. Configurer l'Ingress
```bash
kubectl apply -f ingress.yaml
```

## 🔍 Vérification du déploiement

### Vérifier les pods
```bash
kubectl get pods -n portfolio
```

### Vérifier les services
```bash
kubectl get svc -n portfolio
```

### Vérifier l'ingress
```bash
kubectl get ingress -n portfolio
```

### Voir les logs d'un pod
```bash
# Backend
kubectl logs -f deployment/backend -n portfolio

# Frontend
kubectl logs -f deployment/frontend -n portfolio

# MongoDB
kubectl logs -f deployment/mongodb -n portfolio
```

## 🌐 Accès à l'application

### Configuration du fichier hosts

**Windows:** `C:\Windows\System32\drivers\etc\hosts`
**Linux/Mac:** `/etc/hosts`

Ajoutez cette ligne:
```
127.0.0.1 portfolio.local
```

### Accès
- **Application:** http://portfolio.local
- **API Backend:** http://portfolio.local/api/projects

## 🔧 Configuration

### Variables d'environnement Backend

Modifiez `backend-deployment.yaml` pour ajuster:
- `PORT`: Port du serveur (défaut: 5000)
- `NODE_ENV`: Environnement (production/development)
- `MONGODB_URI`: URI de connexion MongoDB

### Secrets MongoDB

Modifiez `mongodb-deployment.yaml` pour changer:
- `MONGO_INITDB_ROOT_USERNAME`: Nom d'utilisateur admin
- `MONGO_INITDB_ROOT_PASSWORD`: Mot de passe admin

## 📊 Scaling

### Augmenter le nombre de replicas

```bash
# Backend
kubectl scale deployment backend --replicas=3 -n portfolio

# Frontend
kubectl scale deployment frontend --replicas=3 -n portfolio
```

## 🗑️ Suppression

### Supprimer tous les composants
```bash
kubectl delete namespace portfolio
```

### Supprimer un composant spécifique
```bash
kubectl delete -f backend-deployment.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f mongodb-deployment.yaml
```

## 🔄 Mise à jour

### Via Jenkins (Recommandé)

Les mises à jour sont **automatiques** :
1. **Commitez** votre code : `git push`
2. **Jenkins détecte** le changement (SCM polling toutes les minutes)
3. **Jenkins build** et déploie automatiquement
4. **Rolling update** : zero downtime

### Mise à jour manuelle (si nécessaire)

```bash
# Mettre à jour une image
kubectl set image deployment/backend backend=dembouz7/portfolio-backend:v1.0.27 -n portfolio
kubectl set image deployment/frontend frontend=dembouz7/portfolio-frontend:v1.0.27 -n portfolio

# Redémarrer un déploiement
kubectl rollout restart deployment/backend -n portfolio
kubectl rollout restart deployment/frontend -n portfolio
```

## 🐛 Dépannage

### Pod en erreur
```bash
kubectl describe pod <pod-name> -n portfolio
kubectl logs <pod-name> -n portfolio
```

### Service non accessible
```bash
kubectl get endpoints -n portfolio
kubectl describe service <service-name> -n portfolio
```

### Ingress non fonctionnel
```bash
# Vérifier que l'Ingress Controller est installé
kubectl get pods -n ingress-nginx

# Installer NGINX Ingress Controller si nécessaire
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

## 📈 Monitoring

### Ressources utilisées
```bash
kubectl top pods -n portfolio
kubectl top nodes
```

### Événements
```bash
kubectl get events -n portfolio --sort-by='.lastTimestamp'
```

## 🔐 Sécurité

### Créer un secret pour les credentials
```bash
kubectl create secret generic backend-secret \
  --from-literal=MONGODB_URI='mongodb://user:pass@mongodb:27017/portfolio' \
  -n portfolio
```

### Utiliser des secrets externes (Sealed Secrets, Vault, etc.)
Recommandé pour les environnements de production.

## 📚 Architecture

```
┌─────────────────────────────────────────┐
│           Ingress (NGINX)               │
│         portfolio.local                 │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┐
      │             │
┌─────▼─────┐ ┌────▼──────┐
│ Frontend  │ │  Backend  │
│  (React)  │ │ (Express) │
│  Port 80  │ │ Port 5000 │
└───────────┘ └─────┬─────┘
                    │
              ┌─────▼──────┐
              │  MongoDB   │
              │  Port 27017│
              └────────────┘
```

## 🎯 Bonnes pratiques

1. **Utilisez des namespaces** pour isoler les environnements
2. **Définissez des resource limits** pour éviter la surconsommation
3. **Configurez des health checks** (liveness/readiness probes)
4. **Utilisez des secrets** pour les données sensibles
5. **Activez le monitoring** (Prometheus, Grafana)
6. **Mettez en place des backups** pour MongoDB
7. **Utilisez des PersistentVolumes** pour les données persistantes

## 📞 Support

Pour toute question ou problème, consultez la documentation Kubernetes officielle:
https://kubernetes.io/docs/
