# Guide Complet : Intégration SonarQube avec Jenkins

**Date:** 26 Mai 2026  
**Objectif:** Ajouter l'analyse de qualité du code avec SonarQube dans le pipeline CI/CD

---

## Table des Matières

1. [Installation de SonarQube](#1-installation-de-sonarqube)
2. [Configuration Initiale SonarQube](#2-configuration-initiale-sonarqube)
3. [Configuration Jenkins](#3-configuration-jenkins)
4. [Mise à Jour du Jenkinsfile](#4-mise-à-jour-du-jenkinsfile)
5. [Test et Vérification](#5-test-et-vérification)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Installation de SonarQube

### 1.1 Démarrer SonarQube avec Docker Compose

```bash
docker-compose -f docker-compose.sonarqube.yml up -d
```

**Services démarrés :**
- SonarQube : http://localhost:9000
- PostgreSQL : Base de données pour SonarQube

### 1.2 Vérifier que SonarQube est Démarré

```bash
# Voir les logs
docker logs -f sonarqube

# Attendre le message "SonarQube is operational"
```

**Temps de démarrage :** 2-3 minutes

### 1.3 Accéder à SonarQube

1. Ouvrez : http://localhost:9000
2. **Credentials par défaut :**
   - Username: `admin`
   - Password: `admin`
3. Vous serez invité à changer le mot de passe
4. **Nouveau mot de passe :** `admin123` (ou votre choix)

---

## 2. Configuration Initiale SonarQube

### 2.1 Créer un Token d'Authentification

1. Connectez-vous à SonarQube
2. Cliquez sur votre avatar (en haut à droite) > **My Account**
3. Onglet **Security**
4. Section **Generate Tokens**
5. **Name**: `Jenkins`
6. **Type**: `Global Analysis Token`
7. **Expires in**: `No expiration`
8. Cliquez sur **Generate**
9. **Copiez le token** (vous ne le verrez qu'une fois !)

**Exemple de token :**
```
squ_1234567890abcdef1234567890abcdef12345678
```

**⚠️ IMPORTANT : Gardez ce token, vous en aurez besoin pour Jenkins !**

### 2.2 Créer le Projet dans SonarQube

1. Page d'accueil SonarQube > **Create Project**
2. **Manually**
3. **Project key**: `portfolio-cicd`
4. **Display name**: `Portfolio CI/CD`
5. **Main branch name**: `master`
6. Cliquez sur **Set Up**
7. **How do you want to analyze your repository?**: **With Jenkins**
8. **DevOps platform**: **GitHub** (ou autre)
9. Suivez les instructions affichées

---

## 3. Configuration Jenkins

### 3.1 Installer le Plugin SonarQube Scanner

1. **Manage Jenkins** > **Manage Plugins**
2. **Available plugins**
3. Recherchez : `SonarQube Scanner`
4. Cochez la case
5. **Install without restart**
6. Attendez la fin de l'installation

### 3.2 Configurer le Serveur SonarQube dans Jenkins

1. **Manage Jenkins** > **Configure System**
2. Descendez jusqu'à **SonarQube servers**
3. Cochez **Environment variables** > **Enable injection of SonarQube server configuration**
4. Cliquez sur **Add SonarQube**
5. Remplissez :
   ```
   Name: SonarQube
   Server URL: http://sonarqube:9000
   ```
6. **Server authentication token** :
   - Cliquez sur **Add** > **Jenkins**
   - Kind: **Secret text**
   - Secret: [Collez le token SonarQube]
   - ID: `sonarqube-token`
   - Description: `SonarQube Token`
   - **Add**
7. Sélectionnez le token que vous venez de créer
8. **Save**

### 3.3 Configurer SonarQube Scanner

1. **Manage Jenkins** > **Global Tool Configuration**
2. Descendez jusqu'à **SonarQube Scanner**
3. Cliquez sur **Add SonarQube Scanner**
4. Remplissez :
   ```
   Name: SonarQube Scanner
   Install automatically: ✅ Coché
   Version: SonarQube Scanner 6.2.1.4610 (ou la dernière version)
   ```
5. **Save**

---

## 4. Mise à Jour du Jenkinsfile

### 4.1 Ajouter le Stage SonarQube

Ajoutez ce stage après le stage **Checkout** :

```groovy
stage('SonarQube Analysis') {
    steps {
        script {
            def scannerHome = tool 'SonarQube Scanner'
            withSonarQubeEnv('SonarQube') {
                sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=portfolio-cicd \
                    -Dsonar.projectName='Portfolio CI/CD' \
                    -Dsonar.sources=express-js/src,react-js/src \
                    -Dsonar.exclusions='**/node_modules/**,**/build/**,**/dist/**' \
                    -Dsonar.javascript.lcov.reportPaths=express-js/coverage/lcov.info,react-js/coverage/lcov.info
                """
            }
        }
    }
}
```

### 4.2 Ajouter Quality Gate (Optionnel)

Ajoutez ce stage après **SonarQube Analysis** :

```groovy
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```

### 4.3 Jenkinsfile Complet avec SonarQube

```groovy
pipeline {
    agent any
    
    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
    }
    
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
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube Scanner'
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=portfolio-cicd \
                            -Dsonar.projectName='Portfolio CI/CD' \
                            -Dsonar.sources=express-js/src,react-js/src \
                            -Dsonar.exclusions='**/node_modules/**,**/build/**,**/dist/**' \
                            -Dsonar.javascript.lcov.reportPaths=express-js/coverage/lcov.info,react-js/coverage/lcov.info
                        """
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    sh "echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin"
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
                    sh 'docker stop portfolio-mongodb portfolio-backend portfolio-frontend || true'
                    sh 'docker rm -f portfolio-mongodb portfolio-backend portfolio-frontend || true'
                    sh 'docker-compose -f docker-compose.hub.yml down -v || true'
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
            echo 'Pipeline completed successfully!'
            emailext(
                subject: "Build reussi : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>Build reussi</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Statut:</strong> <span style="color: green;">SUCCES</span></p>
                    <p><strong>SonarQube:</strong> <a href="http://localhost:9000/dashboard?id=portfolio-cicd">Voir le rapport</a></p>
                    <p><a href="${env.BUILD_URL}">Voir les details du build</a></p>
                """,
                to: 'ousinfaye4@gmail.com',
                mimeType: 'text/html'
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext(
                subject: "Build echoue : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>Build echoue</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Statut:</strong> <span style="color: red;">ECHEC</span></p>
                    <p><a href="${env.BUILD_URL}console">Voir les logs du build</a></p>
                """,
                to: 'ousinfaye4@gmail.com',
                mimeType: 'text/html'
            )
        }
    }
}
```

---

## 5. Test et Vérification

### 5.1 Lancer le Build avec SonarQube

1. Commitez et pushez les changements :
   ```bash
   git add Jenkinsfile sonar-project.properties docker-compose.sonarqube.yml
   git commit -m "Add: Integration SonarQube pour analyse de code"
   git push origin master
   ```

2. Jenkins détectera le changement et lancera un build

3. Suivez les logs du stage **SonarQube Analysis**

### 5.2 Vérifier les Résultats dans SonarQube

1. Allez sur http://localhost:9000
2. Cliquez sur le projet **Portfolio CI/CD**
3. Vous verrez :
   - **Bugs** : Erreurs dans le code
   - **Vulnerabilities** : Failles de sécurité
   - **Code Smells** : Mauvaises pratiques
   - **Coverage** : Couverture de tests
   - **Duplications** : Code dupliqué

### 5.3 Interpréter les Résultats

**Quality Gate Status :**
- 🟢 **Passed** : Le code respecte les standards
- 🔴 **Failed** : Le code a des problèmes critiques

**Métriques importantes :**
- **Reliability** : Bugs
- **Security** : Vulnérabilités
- **Maintainability** : Code Smells
- **Coverage** : % de code testé
- **Duplications** : % de code dupliqué

---

## 6. Troubleshooting

### Problème 1 : SonarQube ne démarre pas

**Symptôme :** `docker logs sonarqube` montre des erreurs

**Solutions :**
```bash
# Augmenter la mémoire Docker (minimum 4 GB)
# Vérifier les logs
docker logs sonarqube

# Redémarrer
docker-compose -f docker-compose.sonarqube.yml restart
```

### Problème 2 : Jenkins ne peut pas se connecter à SonarQube

**Symptôme :** `Unable to connect to SonarQube server`

**Solutions :**
1. Vérifiez que SonarQube est accessible : http://localhost:9000
2. Dans Jenkins, utilisez `http://sonarqube:9000` (nom du conteneur)
3. Vérifiez que les conteneurs sont sur le même réseau Docker

### Problème 3 : Token invalide

**Symptôme :** `Authentication failed`

**Solution :**
1. Régénérez un token dans SonarQube
2. Mettez à jour le credential dans Jenkins

### Problème 4 : Quality Gate échoue

**Symptôme :** Le build échoue au stage Quality Gate

**Solutions :**
1. Consultez le rapport SonarQube pour voir les problèmes
2. Corrigez les bugs/vulnérabilités critiques
3. Ou désactivez temporairement le Quality Gate (retirez le stage)

### Problème 5 : Scanner not found

**Symptôme :** `SonarQube Scanner not found`

**Solution :**
1. Manage Jenkins > Global Tool Configuration
2. Vérifiez que SonarQube Scanner est configuré
3. Vérifiez que le nom correspond : `SonarQube Scanner`

---

## Commandes Utiles

```bash
# Démarrer SonarQube
docker-compose -f docker-compose.sonarqube.yml up -d

# Arrêter SonarQube
docker-compose -f docker-compose.sonarqube.yml down

# Voir les logs
docker logs -f sonarqube

# Redémarrer SonarQube
docker restart sonarqube

# Nettoyer les données (⚠️ perte de données)
docker-compose -f docker-compose.sonarqube.yml down -v
```

---

## Résumé des Étapes

1. ✅ Démarrer SonarQube : `docker-compose -f docker-compose.sonarqube.yml up -d`
2. ✅ Se connecter : http://localhost:9000 (admin/admin)
3. ✅ Créer un token dans SonarQube
4. ✅ Installer le plugin SonarQube Scanner dans Jenkins
5. ✅ Configurer le serveur SonarQube dans Jenkins
6. ✅ Ajouter le stage SonarQube Analysis dans le Jenkinsfile
7. ✅ Commiter et pusher
8. ✅ Vérifier les résultats dans SonarQube

---

## Prochaines Étapes

1. **Ajouter des tests unitaires** pour améliorer la couverture
2. **Configurer des Quality Gates personnalisés**
3. **Intégrer des règles de qualité spécifiques**
4. **Ajouter des badges SonarQube dans le README**

---

**Votre pipeline CI/CD avec analyse de qualité du code est maintenant prêt !** 🎉
