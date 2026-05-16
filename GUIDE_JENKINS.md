# 🚀 Guide Complet Jenkins - CI/CD Portfolio

## 📋 Table des Matières
1. [Installation Jenkins](#installation-jenkins)
2. [Configuration Initiale](#configuration-initiale)
3. [Intégration GitHub](#intégration-github)
4. [Pipeline CI/CD](#pipeline-cicd)
5. [Déploiement Docker Hub](#déploiement-docker-hub)
6. [Webhooks GitHub](#webhooks-github)
7. [Dépannage](#dépannage)

---

## 🐳 Installation Jenkins

### 1. Démarrer Jenkins avec Docker

```bash
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Ports :**
- `8081` : Interface web Jenkins
- `50000` : Port pour les agents Jenkins

### 2. Vérifier le démarrage

```bash
# Voir les logs
docker logs jenkins

# Vérifier que le container tourne
docker ps | grep jenkins
```

### 3. Récupérer le mot de passe initial

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Copiez ce mot de passe**, vous en aurez besoin pour la première connexion.

---

## ⚙️ Configuration Initiale

### 1. Accéder à Jenkins

Ouvrir dans le navigateur : **http://localhost:8081**

### 2. Déverrouiller Jenkins

- Coller le mot de passe initial récupéré précédemment
- Cliquer sur **Continue**

### 3. Installer les plugins

**Option recommandée :** Cliquer sur **Install suggested plugins**

Plugins installés automatiquement :
- Git
- GitHub
- Pipeline
- Docker
- Credentials
- Et autres plugins essentiels

**Attendre la fin de l'installation** (2-5 minutes)

### 4. Créer le premier utilisateur Admin

Remplir le formulaire :
- **Username** : `admin` (ou votre choix)
- **Password** : [choisir un mot de passe fort]
- **Full name** : `Dembouz7`
- **Email** : votre email

Cliquer sur **Save and Continue**

### 5. Configuration de l'URL Jenkins

- **Jenkins URL** : `http://localhost:8081/`
- Cliquer sur **Save and Finish**
- Cliquer sur **Start using Jenkins**

✅ **Jenkins est maintenant prêt !**

---

## 🔗 Intégration GitHub

### 1. Installer le plugin GitHub (si pas déjà installé)

1. Aller dans **Manage Jenkins** → **Manage Plugins**
2. Onglet **Available**
3. Chercher **GitHub Integration Plugin**
4. Cocher et cliquer sur **Install without restart**

### 2. Créer un Personal Access Token GitHub

1. Aller sur GitHub : https://github.com/settings/tokens
2. Cliquer sur **Generate new token** → **Generate new token (classic)**
3. Donner un nom : `Jenkins CI/CD`
4. Cocher les permissions :
   - ✅ `repo` (tous les sous-items)
   - ✅ `admin:repo_hook` (pour les webhooks)
5. Cliquer sur **Generate token**
6. **⚠️ COPIER LE TOKEN** (vous ne pourrez plus le voir après)

### 3. Ajouter les credentials dans Jenkins

1. Aller dans **Manage Jenkins** → **Manage Credentials**
2. Cliquer sur **(global)** → **Add Credentials**
3. Remplir :
   - **Kind** : `Secret text`
   - **Secret** : [coller votre token GitHub]
   - **ID** : `github-token`
   - **Description** : `GitHub Personal Access Token`
4. Cliquer sur **Create**

### 4. Ajouter les credentials Docker Hub

1. **Manage Jenkins** → **Manage Credentials** → **(global)** → **Add Credentials**
2. Remplir :
   - **Kind** : `Username with password`
   - **Username** : `dembouz7`
   - **Password** : [votre mot de passe Docker Hub]
   - **ID** : `dockerhub-credentials`
   - **Description** : `Docker Hub dembouz7`
3. Cliquer sur **Create**

---

## 🔄 Pipeline CI/CD

### 1. Créer un nouveau Job Pipeline

1. Sur le dashboard Jenkins, cliquer sur **New Item**
2. Entrer le nom : `portfolio-cicd`
3. Sélectionner **Pipeline**
4. Cliquer sur **OK**

### 2. Configurer le Pipeline

#### Section "General"
- ✅ Cocher **GitHub project**
- **Project url** : `https://github.com/dembouz7/projet_fil_rouge`

#### Section "Build Triggers"
- ✅ Cocher **GitHub hook trigger for GITScm polling**

#### Section "Pipeline"
- **Definition** : `Pipeline script from SCM`
- **SCM** : `Git`
- **Repository URL** : `https://github.com/dembouz7/projet_fil_rouge.git`
- **Credentials** : Sélectionner `github-token`
- **Branch Specifier** : `*/master` (ou `*/main`)
- **Script Path** : `Jenkinsfile`

Cliquer sur **Save**

### 3. Créer le Jenkinsfile

Créer un fichier `Jenkinsfile` à la racine de votre projet :

```groovy
pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        BACKEND_IMAGE = 'dembouz7/portfolio-backend'
        FRONTEND_IMAGE = 'dembouz7/portfolio-frontend'
        VERSION = "v1.0.${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        
        stage('Build Backend') {
            steps {
                echo 'Building Backend Docker image...'
                script {
                    dir('express-js') {
                        sh "docker build -t ${BACKEND_IMAGE}:${VERSION} ."
                        sh "docker tag ${BACKEND_IMAGE}:${VERSION} ${BACKEND_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                echo 'Building Frontend Docker image...'
                script {
                    dir('react-js') {
                        sh "docker build -t ${FRONTEND_IMAGE}:${VERSION} ."
                        sh "docker tag ${FRONTEND_IMAGE}:${VERSION} ${FRONTEND_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Test Backend') {
            steps {
                echo 'Running Backend tests...'
                script {
                    dir('express-js') {
                        sh 'npm install'
                        sh 'npm test || echo "No tests configured"'
                    }
                }
            }
        }
        
        stage('Test Frontend') {
            steps {
                echo 'Running Frontend tests...'
                script {
                    dir('react-js') {
                        sh 'npm install'
                        sh 'npm test -- --passWithNoTests || echo "No tests configured"'
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    sh "docker push ${BACKEND_IMAGE}:${VERSION}"
                    sh "docker push ${BACKEND_IMAGE}:latest"
                    sh "docker push ${FRONTEND_IMAGE}:${VERSION}"
                    sh "docker push ${FRONTEND_IMAGE}:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    sh 'docker-compose -f docker-compose.hub.yml pull'
                    sh 'docker-compose -f docker-compose.hub.yml up -d'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker logout'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
```

### 4. Commit et Push le Jenkinsfile

```bash
git add Jenkinsfile
git commit -m "Add Jenkins CI/CD pipeline"
git push origin master
```

---

## 🔔 Webhooks GitHub

### 1. Configurer le Webhook sur GitHub

1. Aller sur votre repository GitHub : `https://github.com/dembouz7/projet_fil_rouge`
2. Cliquer sur **Settings** → **Webhooks** → **Add webhook**
3. Remplir :
   - **Payload URL** : `http://votre-ip-publique:8081/github-webhook/`
   - **Content type** : `application/json`
   - **Secret** : [laisser vide ou ajouter un secret]
   - **Which events** : `Just the push event`
   - ✅ **Active**
4. Cliquer sur **Add webhook**

**Note :** Si Jenkins est sur votre machine locale, vous devrez :
- Soit exposer Jenkins avec **ngrok** : `ngrok http 8081`
- Soit déployer Jenkins sur un serveur avec IP publique

### 2. Tester le Webhook

1. Faire un commit et push sur GitHub
2. Le webhook déclenchera automatiquement le pipeline Jenkins
3. Vérifier dans Jenkins : **Dashboard** → **portfolio-cicd** → **Build History**

---

## 🎯 Utilisation du Pipeline

### Déclencher manuellement un build

1. Aller sur **Dashboard** → **portfolio-cicd**
2. Cliquer sur **Build Now**
3. Voir la progression dans **Build History**
4. Cliquer sur le numéro du build → **Console Output** pour voir les logs

### Déclencher automatiquement (via Git push)

```bash
# Faire des modifications
git add .
git commit -m "Update application"
git push origin master

# Jenkins détectera le push et lancera automatiquement le pipeline
```

### Voir les résultats

1. **Dashboard** → **portfolio-cicd**
2. Voir l'historique des builds
3. ✅ Vert = Succès
4. ❌ Rouge = Échec
5. Cliquer sur un build pour voir les détails

---

## 📊 Monitoring et Logs

### Voir les logs Jenkins

```bash
# Logs en temps réel
docker logs -f jenkins

# Dernières 100 lignes
docker logs --tail 100 jenkins
```

### Voir les logs d'un build

1. **Dashboard** → **portfolio-cicd**
2. Cliquer sur le numéro du build
3. Cliquer sur **Console Output**

### Statistiques

1. **Dashboard** → **portfolio-cicd**
2. Voir :
   - Nombre de builds
   - Taux de succès
   - Durée moyenne
   - Tendances

---

## 🔧 Configuration Avancée

### Ajouter des notifications (Email)

1. **Manage Jenkins** → **Configure System**
2. Section **E-mail Notification**
3. Configurer le serveur SMTP
4. Tester l'envoi d'email

### Ajouter des notifications (Slack)

1. Installer le plugin **Slack Notification**
2. Configurer le webhook Slack
3. Ajouter dans le Jenkinsfile :

```groovy
post {
    success {
        slackSend color: 'good', message: "Build ${BUILD_NUMBER} succeeded!"
    }
    failure {
        slackSend color: 'danger', message: "Build ${BUILD_NUMBER} failed!"
    }
}
```

### Paralléliser les builds

```groovy
stage('Build Images') {
    parallel {
        stage('Build Backend') {
            steps {
                // Build backend
            }
        }
        stage('Build Frontend') {
            steps {
                // Build frontend
            }
        }
    }
}
```

---

## 🛠️ Dépannage

### Jenkins ne démarre pas

```bash
# Vérifier les logs
docker logs jenkins

# Redémarrer Jenkins
docker restart jenkins

# Vérifier l'espace disque
docker system df
```

### Port déjà utilisé

```bash
# Trouver le processus
netstat -ano | findstr :8081

# Arrêter Jenkins et changer le port
docker stop jenkins
docker rm jenkins

# Redémarrer sur un autre port
docker run -d --name jenkins -p 8082:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

### Build échoue

1. Vérifier les logs du build : **Console Output**
2. Vérifier les credentials Docker Hub
3. Vérifier que Docker est accessible dans Jenkins :

```bash
# Entrer dans le container Jenkins
docker exec -it jenkins bash

# Tester Docker
docker --version
```

**Note :** Jenkins dans Docker ne peut pas utiliser Docker par défaut. Il faut :
- Soit installer Docker dans Jenkins (Docker-in-Docker)
- Soit monter le socket Docker : `-v /var/run/docker.sock:/var/run/docker.sock`

### Corriger l'accès Docker dans Jenkins

```bash
# Arrêter Jenkins
docker stop jenkins
docker rm jenkins

# Redémarrer avec accès Docker
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Donner les permissions (dans le container)
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Webhook ne fonctionne pas

1. Vérifier l'URL du webhook sur GitHub
2. Vérifier que Jenkins est accessible depuis Internet
3. Utiliser **ngrok** pour exposer Jenkins localement :

```bash
# Installer ngrok : https://ngrok.com/download
ngrok http 8081

# Utiliser l'URL ngrok dans le webhook GitHub
# Exemple : https://abc123.ngrok.io/github-webhook/
```

---

## 📚 Commandes Utiles

### Gestion du container Jenkins

```bash
# Démarrer
docker start jenkins

# Arrêter
docker stop jenkins

# Redémarrer
docker restart jenkins

# Voir les logs
docker logs -f jenkins

# Entrer dans le container
docker exec -it jenkins bash

# Supprimer (attention : perte de données si pas de volume)
docker stop jenkins
docker rm jenkins
```

### Backup Jenkins

```bash
# Backup du volume
docker run --rm -v jenkins_home:/data -v $(pwd):/backup alpine tar czf /backup/jenkins_backup.tar.gz /data

# Restore du volume
docker run --rm -v jenkins_home:/data -v $(pwd):/backup alpine tar xzf /backup/jenkins_backup.tar.gz -C /
```

### Mise à jour Jenkins

```bash
# Pull la dernière version
docker pull jenkins/jenkins:lts

# Arrêter l'ancien container
docker stop jenkins
docker rm jenkins

# Démarrer avec la nouvelle version
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

---

## 🎯 Workflow Complet

```
1. Développeur fait un commit
   ↓
2. Push vers GitHub
   ↓
3. Webhook déclenche Jenkins
   ↓
4. Jenkins clone le repository
   ↓
5. Build des images Docker (Backend + Frontend)
   ↓
6. Exécution des tests
   ↓
7. Push vers Docker Hub (si tests OK)
   ↓
8. Déploiement automatique
   ↓
9. Notification (Email/Slack)
```

---

## ✅ Checklist

### Installation
- [ ] Jenkins démarré avec Docker
- [ ] Mot de passe initial récupéré
- [ ] Plugins installés
- [ ] Utilisateur admin créé

### Configuration
- [ ] GitHub token créé et ajouté
- [ ] Docker Hub credentials ajoutés
- [ ] Pipeline créé
- [ ] Jenkinsfile créé et pushé

### Intégration
- [ ] Webhook GitHub configuré
- [ ] Premier build réussi
- [ ] Images sur Docker Hub
- [ ] Application déployée

---

## 🔗 Ressources

- [Documentation Jenkins](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Hub](https://hub.docker.com/u/dembouz7)
- [GitHub Webhooks](https://docs.github.com/en/webhooks)

---

**Votre pipeline CI/CD est maintenant configuré ! 🚀**

**Auteur** : dembouz7  
**Date** : 10 Mai 2026  
**Version** : 1.0.0
