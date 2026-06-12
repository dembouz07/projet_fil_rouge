# 🎯 Guide de Présentation - Déploiement Kubernetes

## 📋 Plan de Présentation (10-15 minutes)

### 1️⃣ Introduction (2 min)

**Qu'est-ce que Kubernetes ?**
- Kubernetes est un orchestrateur de conteneurs qui automatise le déploiement, la mise à l'échelle et la gestion des applications conteneurisées
- Il assure la haute disponibilité, la scalabilité automatique et la gestion des défaillances

**Pourquoi Kubernetes pour ce projet ?**
- ✅ Haute disponibilité : redémarrage automatique des pods défaillants
- ✅ Scalabilité : augmentation/réduction automatique selon la charge
- ✅ Gestion simplifiée : déclaration de l'état désiré
- ✅ Production-ready : utilisé par les grandes entreprises (Google, Microsoft, etc.)

---

### 2️⃣ Architecture de l'Application (3 min)

**Montrer le schéma :**

```
┌─────────────────────────────────────────────────┐
│              UTILISATEUR                        │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│         INGRESS (portfolio.local)               │
│     • Routage HTTP                              │
│     • Point d'entrée unique                     │
└────────────┬──────────────────┬─────────────────┘
             │                  │
             ▼                  ▼
┌─────────────────────┐  ┌──────────────────────┐
│   Frontend Service  │  │   Backend Service    │
│   (ClusterIP)       │  │   (ClusterIP)        │
└──────┬──────────────┘  └──────┬───────────────┘
       │                        │
       ▼                        ▼
┌─────────────────────┐  ┌──────────────────────┐
│  Frontend Pods (2)  │  │  Backend Pods (3)    │
│  • React App        │  │  • Express.js API    │
│  • Nginx            │  │  • Node.js           │
└─────────────────────┘  └──────┬───────────────┘
                                │
                                ▼
                         ┌──────────────────────┐
                         │  MongoDB Service     │
                         │  (ClusterIP)         │
                         └──────┬───────────────┘
                                │
                                ▼
                         ┌──────────────────────┐
                         │  MongoDB Pod (1)     │
                         │  • Base de données   │
                         │  • Persistent Volume │
                         └──────────────────────┘
```

**Composants :**
- **3 Deployments** : Frontend (2 réplicas), Backend (3 réplicas), MongoDB (1 réplica)
- **3 Services** : pour la communication interne
- **1 Ingress** : pour l'accès externe via `portfolio.local`
- **1 Namespace** : `portfolio` pour isoler les ressources

---

### 3️⃣ Démonstration des Fichiers Kubernetes (4 min)

#### **A. Namespace (`namespace.yaml`)**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: portfolio
```
**Explication :** Isole les ressources du projet des autres applications

---

#### **B. MongoDB Deployment (`mongodb-deployment.yaml`)**

**Points clés à montrer :**
```yaml
replicas: 1                    # ← 1 seule instance de MongoDB
image: mongo:8.0-rc            # ← Image Docker officielle
env:                           # ← Variables d'environnement
  - name: MONGO_INITDB_ROOT_USERNAME
    value: "admin"
volumeMounts:                  # ← Persistance des données
  - name: mongodb-data
    mountPath: /data/db
```

**Dire :** 
- "MongoDB utilise un volume persistant pour conserver les données même si le pod redémarre"
- "Le service MongoDB expose le port 27017 pour les connexions internes"

---

#### **C. Backend Deployment (`backend-deployment.yaml`)**

**Points clés à montrer :**
```yaml
replicas: 3                    # ← 3 instances pour la haute disponibilité
strategy:
  type: RollingUpdate          # ← Mise à jour progressive sans downtime
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
env:
  - name: MONGODB_URI          # ← Connexion à MongoDB via DNS
    value: "mongodb://admin:admin123@mongodb-service:27017/portfolio?authSource=admin"
livenessProbe:                 # ← Vérification santé du pod
  httpGet:
    path: /api/health
    port: 5000
```

**Dire :**
- "3 réplicas assurent que l'API reste disponible même si un pod tombe"
- "Rolling update : les nouveaux pods démarrent avant que les anciens s'arrêtent"
- "Liveness probe : Kubernetes redémarre automatiquement les pods qui ne répondent plus"

---

#### **D. Frontend Deployment (`frontend-deployment.yaml`)**

**Points clés à montrer :**
```yaml
replicas: 2                    # ← 2 instances
image: dembouz7/portfolio-frontend:latest
env:
  - name: REACT_APP_API_URL
    value: "http://portfolio.local/api"
```

**Dire :**
- "Le frontend est servi par Nginx pour de meilleures performances"
- "2 réplicas pour répartir la charge utilisateur"

---

#### **E. Ingress (`ingress.yaml`)**

**Points clés à montrer :**
```yaml
spec:
  rules:
  - host: portfolio.local      # ← Nom de domaine
    http:
      paths:
      - path: /api             # ← Routes API vers backend
        pathType: Prefix
        backend:
          service:
            name: backend-service
      - path: /                # ← Routes web vers frontend
        pathType: Prefix
        backend:
          service:
            name: frontend-service
```

**Dire :**
- "L'Ingress route automatiquement /api vers le backend et le reste vers le frontend"
- "Un seul point d'entrée pour toute l'application"

---

### 4️⃣ Démonstration en Direct (5 min)

#### **Étape 1 : Montrer l'état actuel**
```powershell
# Afficher tous les pods
kubectl get pods -n portfolio

# Afficher les services
kubectl get svc -n portfolio

# Afficher l'ingress
kubectl get ingress -n portfolio
```

**Commenter :**
- "Voici nos pods en cours d'exécution. Voyez les 3 backend et 2 frontend"
- "Tous sont en état 'Running' et 'Ready'"

---

#### **Étape 2 : Démontrer la haute disponibilité**
```powershell
# Supprimer un pod backend
kubectl delete pod <nom-du-pod-backend> -n portfolio

# Montrer que Kubernetes recrée automatiquement le pod
kubectl get pods -n portfolio -w
```

**Commenter :**
- "J'ai supprimé un pod backend volontairement"
- "Kubernetes détecte ça et recrée automatiquement un nouveau pod pour maintenir 3 réplicas"
- "L'application continue de fonctionner sans interruption"

---

#### **Étape 3 : Montrer le scaling**
```powershell
# Scaler le frontend à 4 réplicas
kubectl scale deployment frontend --replicas=4 -n portfolio

# Vérifier
kubectl get pods -n portfolio | grep frontend
```

**Commenter :**
- "En une seule commande, je peux augmenter le nombre de pods"
- "Utile en période de forte charge (Black Friday, etc.)"

---

#### **Étape 4 : Voir les logs**
```powershell
# Logs d'un pod backend
kubectl logs <nom-pod-backend> -n portfolio --tail=20
```

**Commenter :**
- "On peut facilement voir les logs de chaque pod pour le debugging"

---

#### **Étape 5 : Tester l'application**
```powershell
# Ouvrir le navigateur
start http://portfolio.local
```

**Montrer :**
- ✅ L'application fonctionne
- ✅ Les données sont persistées (MongoDB)
- ✅ Navigation fluide

---

### 5️⃣ Intégration CI/CD avec Jenkins (2 min)

**Montrer le Jenkinsfile - Section Kubernetes :**
```groovy
stage('Deploy to Kubernetes') {
    when {
        expression { params.DEPLOY_TARGET == 'kubernetes' }
    }
    steps {
        script {
            // Mise à jour des images
            sh """
                kubectl set image deployment/backend \
                    backend=${BACKEND_IMAGE}:${VERSION} -n portfolio
                kubectl set image deployment/frontend \
                    frontend=${FRONTEND_IMAGE}:${VERSION} -n portfolio
            """
            
            // Appliquer les configurations
            sh """
                kubectl apply -f k8s/namespace.yaml
                kubectl apply -f k8s/mongodb-deployment.yaml
                kubectl apply -f k8s/backend-deployment.yaml
                kubectl apply -f k8s/frontend-deployment.yaml
                kubectl apply -f k8s/ingress.yaml
            """
            
            // Attendre le déploiement
            sh """
                kubectl rollout status deployment/backend -n portfolio
                kubectl rollout status deployment/frontend -n portfolio
            """
        }
    }
}
```

**Expliquer le flux :**
1. **Push Git** → Jenkins détecte le changement
2. **Build** → Création des images Docker
3. **Push** → Envoi vers Docker Hub
4. **Deploy** → Kubernetes télécharge les nouvelles images
5. **Rolling Update** → Mise à jour progressive sans coupure
6. **Health Check** → Vérification que tout fonctionne
7. **Email** → Notification de succès/échec

**Dire :**
- "Tout ce processus est automatisé"
- "Du commit Git à la production en quelques minutes"
- "Zero downtime : l'application reste accessible pendant la mise à jour"

---

### 6️⃣ Avantages vs Docker Compose (1 min)

| Aspect | Docker Compose | Kubernetes |
|--------|---------------|-----------|
| **Production** | ❌ Non recommandé | ✅ Production-ready |
| **Scaling** | ⚠️ Manuel | ✅ Automatique |
| **Auto-healing** | ❌ Non | ✅ Oui (redémarrage auto) |
| **Load balancing** | ⚠️ Basique | ✅ Avancé |
| **Rolling updates** | ❌ Non | ✅ Oui |
| **Multi-serveurs** | ❌ Non | ✅ Oui (cluster) |

**Dire :**
- "Docker Compose est parfait pour le développement local"
- "Kubernetes est le standard industriel pour la production"

---

### 7️⃣ Conclusion (1 min)

**Résumé :**
✅ Architecture microservices déployée sur Kubernetes  
✅ Haute disponibilité avec plusieurs réplicas  
✅ Déploiement automatisé via Jenkins CI/CD  
✅ Scaling facile selon la charge  
✅ Auto-réparation des pods défaillants  
✅ Zero downtime lors des mises à jour  

**Ouverture :**
- "Prochaines étapes possibles :"
  - Ajout d'un autoscaling basé sur le CPU (HPA)
  - Monitoring avec Prometheus + Grafana
  - Logs centralisés avec ELK Stack
  - Déploiement sur un cluster cloud (AWS EKS, Azure AKS, GCP GKE)

---

## 🎬 Script de Présentation Mot à Mot

### Ouverture
> "Bonjour, je vais vous présenter le déploiement Kubernetes de mon application portfolio. Kubernetes est un orchestrateur de conteneurs qui permet de gérer des applications en production avec haute disponibilité et scalabilité automatique."

### Architecture
> "Mon application est composée de 3 parties : un frontend React, un backend Node.js Express et une base MongoDB. J'ai déployé 2 instances du frontend, 3 du backend pour la résilience, et 1 MongoDB avec persistance des données."

### Fichiers Kubernetes
> "Chaque composant est défini de manière déclarative dans des fichiers YAML. Par exemple, pour le backend, je spécifie que je veux 3 réplicas, une stratégie de rolling update pour des déploiements sans coupure, et des health checks pour que Kubernetes sache si un pod fonctionne correctement."

### Démo Live
> "Voyons ça en action. Actuellement tous mes pods sont Running. Maintenant, je vais simuler une panne en supprimant un pod backend... Voyez ? Kubernetes a immédiatement détecté la suppression et recrée automatiquement un nouveau pod pour maintenir mes 3 réplicas. L'application n'a jamais cessé de fonctionner."

> "Je peux aussi scaler facilement. En une commande, je passe de 2 à 4 instances de frontend. Utile lors de pics de trafic."

### CI/CD
> "Tout ce processus est automatisé avec Jenkins. Dès qu'un développeur push du code, Jenkins build les images Docker, les envoie sur Docker Hub, puis Kubernetes les déploie automatiquement avec une stratégie de rolling update : les nouveaux pods démarrent avant que les anciens s'arrêtent. Zero downtime."

### Conclusion
> "En résumé, Kubernetes nous offre une plateforme de production robuste avec auto-réparation, scalabilité et déploiements automatisés. C'est le standard industriel utilisé par Google, Microsoft et toutes les grandes entreprises."

---

## 📝 Checklist Avant la Démo

- [ ] Tous les pods sont Running : `kubectl get pods -n portfolio`
- [ ] L'application est accessible : `http://portfolio.local`
- [ ] Jenkins fonctionne : `http://localhost:8080`
- [ ] Préparer un terminal avec les commandes
- [ ] Avoir un navigateur ouvert sur `portfolio.local`
- [ ] Tester la suppression/recréation d'un pod avant
- [ ] Avoir le schéma d'architecture visible

---

## 🎯 Questions Fréquentes

**Q: Pourquoi 3 réplicas pour le backend ?**  
R: Pour assurer la haute disponibilité. Si un pod tombe, les 2 autres continuent à servir les requêtes.

**Q: Comment Kubernetes sait qu'un pod est en panne ?**  
R: Grâce aux liveness et readiness probes qui vérifient régulièrement la santé des pods.

**Q: Que se passe-t-il si un nœud tombe ?**  
R: Kubernetes redéploie automatiquement les pods sur d'autres nœuds disponibles du cluster.

**Q: Comment gérez-vous les secrets (mots de passe) ?**  
R: Actuellement en variables d'environnement, mais en production on utiliserait Kubernetes Secrets ou un vault externe.

**Q: Ça coûte cher ?**  
R: Ici c'est local avec Docker Desktop (gratuit). En production cloud, ça dépend du nombre de nœuds et ressources utilisées.

---

## 🚀 Commandes Utiles Pour la Démo

```powershell
# État général
kubectl get all -n portfolio

# Pods détaillés
kubectl get pods -n portfolio -o wide

# Décrire un pod
kubectl describe pod <pod-name> -n portfolio

# Logs en temps réel
kubectl logs -f <pod-name> -n portfolio

# Supprimer un pod (auto-healing demo)
kubectl delete pod <pod-name> -n portfolio

# Scaler
kubectl scale deployment backend --replicas=5 -n portfolio

# Rollout status
kubectl rollout status deployment/backend -n portfolio

# Rollback si problème
kubectl rollout undo deployment/backend -n portfolio

# Accéder à un pod
kubectl exec -it <pod-name> -n portfolio -- /bin/sh
```

---

**Bonne présentation ! 🎉**
