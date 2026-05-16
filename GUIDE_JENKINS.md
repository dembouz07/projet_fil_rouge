# Guide Complet Jenkins CI/CD

Ce guide vous accompagne dans la mise en place complete d'un pipeline CI/CD avec Jenkins pour votre portfolio.

---

## Table des Matieres

1. [Installation de Jenkins](#installation-de-jenkins)
2. [Configuration Initiale](#configuration-initiale)
3. [Configuration du Projet](#configuration-du-projet)
4. [Webhooks et Notifications](#webhooks-et-notifications)
5. [Utilisation Quotidienne](#utilisation-quotidienne)
6. [Troubleshooting](#troubleshooting)

---

## Installation de Jenkins

### Prerequis

- Java JDK 17 ou superieur
- Docker Desktop installe et en cours d'execution
- Git installe

### Installation sur Windows

#### Option 1 : Installation avec l'installateur Windows

1. Telechargez Jenkins depuis https://www.jenkins.io/download/
2. Executez le fichier `.msi`
3. Suivez l'assistant d'installation
4. Jenkins s'installera comme service Windows
5. Par defaut, Jenkins sera accessible sur http://localhost:8080

#### Option 2 : Installation avec le fichier WAR

1. Telechargez `jenkins.war` depuis https://www.jenkins.io/download/
2. Ouvrez un terminal et executez :
   ```bash
   java -jar jenkins.war --httpPort=8081
   ```
3. Jenkins sera accessible sur http://localhost:8081

### Premier Demarrage

1. Ouvrez votre navigateur sur http://localhost:8081
2. Recuperez le mot de passe initial :
   - Chemin affiche dans le terminal ou
   - Fichier : `C:\ProgramData\Jenkins\.jenkins\secrets\initialAdminPassword`
3. Collez le mot de passe dans l'interface
4. Cliquez sur **Install suggested plugins**
5. Attendez l'installation des plugins
6. Creez votre compte administrateur :
   - Username: admin
   - Password: [votre mot de passe]
   - Full name: [votre nom]
   - Email: [votre email]
7. Confirmez l'URL Jenkins (http://localhost:8081)
8. Cliquez sur **Start using Jenkins**

---

## Configuration Initiale

### Etape 1 : Installer les Plugins Necessaires

1. Allez dans **Manage Jenkins** > **Manage Plugins**
2. Cliquez sur l'onglet **Available plugins**
3. Recherchez et installez les plugins suivants :
   - **Docker Pipeline**
   - **Git Plugin** (normalement deja installe)
   - **Email Extension Plugin**
   - **GitHub Plugin** (si vous utilisez GitHub)
   - **GitLab Plugin** (si vous utilisez GitLab)
4. Cochez les plugins et cliquez sur **Install without restart**

### Etape 2 : Configurer Docker

1. Verifiez que Docker Desktop est en cours d'execution
2. Ouvrez un terminal et testez :
   ```bash
   docker --version
   docker ps
   ```
3. Jenkins utilisera Docker via la ligne de commande

### Etape 3 : Configurer les Credentials Docker Hub

1. Allez dans **Manage Jenkins** > **Manage Credentials**
2. Cliquez sur **(global)** sous **Stores scoped to Jenkins**
3. Cliquez sur **Add Credentials**
4. Remplissez :
   - Kind: **Username with password**
   - Scope: **Global**
   - Username: `dembouz7` (votre username Docker Hub)
   - Password: [votre mot de passe Docker Hub]
   - ID: `dockerhub-credentials`
   - Description: `Docker Hub Credentials`
5. Cliquez sur **Create**

### Etape 4 : Configurer Git

1. Allez dans **Manage Jenkins** > **Global Tool Configuration**
2. Descendez jusqu'a la section **Git**
3. Cliquez sur **Add Git**
4. Name: `Default`
5. Path to Git executable: `git` (ou le chemin complet si necessaire)
6. Cliquez sur **Save**

---

## Configuration du Projet

### Etape 1 : Creer un Nouveau Projet Pipeline

1. Sur la page d'accueil Jenkins, cliquez sur **New Item**
2. Entrez le nom : `portfolio-cicd`
3. Selectionnez **Pipeline**
4. Cliquez sur **OK**

### Etape 2 : Configurer le Pipeline

#### Section General

1. Description : `Pipeline CI/CD pour le portfolio`
2. Cochez **Discard old builds**
   - Max # of builds to keep: `10`

#### Section Build Triggers

1. Cochez **Poll SCM**
2. Schedule : `H/5 * * * *` (verifie toutes les 5 minutes)

#### Section Pipeline

1. Definition : **Pipeline script from SCM**
2. SCM : **Git**
3. Repository URL : `https://github.com/votre-username/votre-repo.git`
   - Ou le chemin local : `C:/laragon/www/projet_fil_rouge`
4. Credentials : 
   - Si repository prive : Ajoutez vos credentials Git
   - Si repository public ou local : Laissez **- none -**
5. Branch Specifier : `*/master` (ou `*/main`)
6. Script Path : `Jenkinsfile`
7. Cliquez sur **Save**

### Etape 3 : Verifier le Jenkinsfile

Le Jenkinsfile doit etre a la racine de votre projet avec ce contenu :

```groovy
pipeline {
    agent any
    
    triggers {
        pollSCM('H/5 * * * *')
    }
    
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
                        bat "docker build -t ${BACKEND_IMAGE}:${VERSION} ."
                        bat "docker tag ${BACKEND_IMAGE}:${VERSION} ${BACKEND_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                echo 'Building Frontend Docker image...'
                script {
                    dir('react-js') {
                        bat "docker build -t ${FRONTEND_IMAGE}:${VERSION} ."
                        bat "docker tag ${FRONTEND_IMAGE}:${VERSION} ${FRONTEND_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    bat "docker login -u %DOCKERHUB_CREDENTIALS_USR% -p %DOCKERHUB_CREDENTIALS_PSW%"
                    bat "docker push ${BACKEND_IMAGE}:${VERSION}"
                    bat "docker push ${BACKEND_IMAGE}:latest"
                    bat "docker push ${FRONTEND_IMAGE}:${VERSION}"
                    bat "docker push ${FRONTEND_IMAGE}:latest"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    bat 'docker stop portfolio-mongodb portfolio-backend portfolio-frontend || echo "No containers to stop"'
                    bat 'docker rm -f portfolio-mongodb portfolio-backend portfolio-frontend || echo "No containers to remove"'
                    bat 'docker-compose -f docker-compose.hub.yml down -v || echo "Docker compose cleanup done"'
                    bat 'docker-compose -f docker-compose.hub.yml pull'
                    bat 'docker-compose -f docker-compose.hub.yml up -d'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            bat 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

### Etape 4 : Lancer le Premier Build

1. Sur la page du projet `portfolio-cicd`, cliquez sur **Build Now**
2. Un nouveau build apparait dans **Build History**
3. Cliquez sur le numero du build (ex: #1)
4. Cliquez sur **Console Output** pour voir les logs en temps reel
5. Attendez la fin du build

---

## Webhooks et Notifications

Pour configurer le declenchement automatique sur push Git et les notifications par email, consultez le guide detaille :

**[CONFIGURATION_WEBHOOK_EMAIL.md](./CONFIGURATION_WEBHOOK_EMAIL.md)**

Ce guide couvre :
- Configuration des notifications email (Gmail, Outlook, SMTP personnalise)
- Declenchement automatique avec Poll SCM
- Configuration des webhooks GitHub/GitLab
- Personnalisation des emails
- Troubleshooting

---

## Utilisation Quotidienne

### Workflow de Developpement

1. **Modifier le code** dans votre editeur
2. **Commiter et pusher** :
   ```bash
   git add .
   git commit -m "Description des changements"
   git push
   ```
3. **Jenkins detecte automatiquement** le changement (dans les 5 minutes)
4. **Le pipeline s'execute** automatiquement :
   - Build des images Docker
   - Push sur Docker Hub
   - Deploiement des conteneurs
5. **Recevoir une notification email** avec le resultat
6. **Verifier le deploiement** :
   - Frontend : http://localhost:3000
   - Backend : http://localhost:5000

### Lancer un Build Manuellement

1. Allez sur la page du projet `portfolio-cicd`
2. Cliquez sur **Build Now**
3. Suivez les logs dans **Console Output**

### Voir l'Historique des Builds

1. Sur la page du projet, consultez **Build History**
2. Cliquez sur un build pour voir les details
3. Consultez :
   - **Console Output** : Logs complets
   - **Changes** : Commits Git inclus
   - **Pipeline** : Vue graphique des stages

### Relancer un Build Echoue

1. Cliquez sur le build echoue
2. Cliquez sur **Rebuild**
3. Ou corrigez le probleme et pushez un nouveau commit

---

## Troubleshooting

### Probleme : Jenkins ne demarre pas

**Solution :**
1. Verifiez que Java est installe : `java -version`
2. Verifiez que le port 8081 n'est pas utilise
3. Consultez les logs : `C:\ProgramData\Jenkins\.jenkins\jenkins.log`

### Probleme : Docker commands not found

**Solution :**
1. Verifiez que Docker Desktop est en cours d'execution
2. Ouvrez un terminal et testez : `docker --version`
3. Redemarrez Jenkins apres l'installation de Docker

### Probleme : Cannot connect to Docker daemon

**Solution :**
1. Demarrez Docker Desktop
2. Attendez que Docker soit completement demarre
3. Relancez le build Jenkins

### Probleme : Authentication failed (Docker Hub)

**Solution :**
1. Verifiez vos credentials Docker Hub dans Jenkins
2. Testez manuellement : `docker login`
3. Recreez les credentials dans Jenkins si necessaire

### Probleme : Container name conflict

**Solution :**
Le Jenkinsfile actuel gere ce probleme automatiquement. Si ca persiste :
```bash
docker stop portfolio-mongodb portfolio-backend portfolio-frontend
docker rm -f portfolio-mongodb portfolio-backend portfolio-frontend
```

### Probleme : Build reste bloque

**Solution :**
1. Cliquez sur le build en cours
2. Cliquez sur le **X rouge** pour l'arreter
3. Verifiez les logs pour identifier le probleme
4. Relancez le build

### Probleme : Git repository not found

**Solution :**
1. Verifiez l'URL du repository dans la configuration du projet
2. Verifiez les credentials Git si repository prive
3. Pour un repository local, utilisez le chemin absolu

---

## Commandes Utiles

### Jenkins

```bash
# Demarrer Jenkins (si installe comme service)
net start jenkins

# Arreter Jenkins
net stop jenkins

# Redemarrer Jenkins
net stop jenkins && net start jenkins
```

### Docker

```bash
# Voir les conteneurs en cours
docker ps

# Voir tous les conteneurs
docker ps -a

# Voir les images
docker images

# Nettoyer les conteneurs arretes
docker container prune

# Nettoyer les images non utilisees
docker image prune

# Voir les logs d'un conteneur
docker logs portfolio-backend
```

### Git

```bash
# Voir le statut
git status

# Voir l'historique
git log --oneline

# Voir les branches
git branch

# Changer de branche
git checkout nom-branche
```

---

## Ameliorations Futures

### Tests Automatises

Ajoutez un stage de tests dans le Jenkinsfile :

```groovy
stage('Test Backend') {
    steps {
        script {
            dir('express-js') {
                bat 'npm install'
                bat 'npm test'
            }
        }
    }
}
```

### Analyse de Code

Integrez SonarQube pour l'analyse de qualite du code.

### Deploiement Multi-Environnements

Ajoutez des stages pour deployer sur :
- Developpement (automatique)
- Staging (automatique)
- Production (manuel avec approbation)

### Notifications Slack/Teams

Integrez des notifications sur Slack ou Microsoft Teams.

### Backup Automatique

Ajoutez un stage pour sauvegarder la base de donnees MongoDB.

---

## Ressources

- Documentation Jenkins : https://www.jenkins.io/doc/
- Docker Hub : https://hub.docker.com/
- Pipeline Syntax : https://www.jenkins.io/doc/book/pipeline/syntax/
- Plugins Jenkins : https://plugins.jenkins.io/

---

## Support

Pour toute question ou probleme :
1. Consultez les logs Jenkins
2. Verifiez la documentation officielle
3. Consultez les guides dans ce repository

Votre pipeline CI/CD est maintenant operationnel !
