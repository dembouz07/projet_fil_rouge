# Fix Complet : Problème Git Jenkins

## Diagnostic

Le problème persiste malgré le nettoyage du workspace. Cela indique un problème de configuration plus profond.

## Solution Complète

### Option 1 : Reconfigurer le Projet (RECOMMANDÉ)

#### Étape 1 : Supprimer le Projet Actuel

1. Allez sur http://localhost:8080
2. Cliquez sur **portfolio-cicd**
3. Dans le menu de gauche, cliquez sur **Delete Project**
4. Confirmez la suppression

#### Étape 2 : Recréer le Projet

1. Page d'accueil Jenkins > **New Item**
2. Name: `portfolio-cicd`
3. Type: **Pipeline**
4. **OK**

#### Étape 3 : Configuration du Nouveau Projet

**General:**
- Description: `Pipeline CI/CD pour le portfolio`
- ✅ Discard old builds
  - Max # of builds to keep: `10`

**Build Triggers:**
- ✅ Poll SCM
- Schedule: `* * * * *`

**Pipeline:**
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/dembouz07/projet_fil_rouge.git`
- Credentials: Sélectionnez **github-credential**
- Branch Specifier: `*/master`
- Script Path: `Jenkinsfile`

**Advanced (cliquez sur Advanced sous Repository URL):**
- ✅ Cochez **Clean before checkout**
- ✅ Cochez **Clean after checkout**

**Save**

#### Étape 4 : Lancer le Premier Build

1. Cliquez sur **Build Now**
2. Suivez les logs dans **Console Output**

---

### Option 2 : Utiliser Pipeline Script Direct (ALTERNATIVE)

Si l'option 1 ne fonctionne pas, utilisez un pipeline script direct :

#### Étape 1 : Modifier la Configuration

1. Projet > **Configure**
2. Section **Pipeline**
3. Definition: **Pipeline script** (au lieu de "from SCM")
4. Copiez-collez le script ci-dessous dans le champ "Script"

#### Étape 2 : Script Pipeline Direct

```groovy
pipeline {
    agent any
    
    triggers {
        pollSCM('* * * * *')
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
                cleanWs()
                git branch: 'master',
                    credentialsId: 'github-credential',
                    url: 'https://github.com/dembouz07/projet_fil_rouge.git'
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
            echo "Images pushed:"
            echo "  - ${BACKEND_IMAGE}:${VERSION}"
            echo "  - ${BACKEND_IMAGE}:latest"
            echo "  - ${FRONTEND_IMAGE}:${VERSION}"
            echo "  - ${FRONTEND_IMAGE}:latest"
            
            emailext(
                subject: "Build reussi : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>Build reussi</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Statut:</strong> <span style="color: green;">SUCCES</span></p>
                    <p><strong>Duree:</strong> ${currentBuild.durationString}</p>
                    
                    <h3>Images deployees:</h3>
                    <ul>
                        <li>${BACKEND_IMAGE}:${VERSION}</li>
                        <li>${BACKEND_IMAGE}:latest</li>
                        <li>${FRONTEND_IMAGE}:${VERSION}</li>
                        <li>${FRONTEND_IMAGE}:latest</li>
                    </ul>
                    
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
                    <p><strong>Duree:</strong> ${currentBuild.durationString}</p>
                    
                    <h3>Erreur:</h3>
                    <p>Consultez les logs pour plus de details.</p>
                    
                    <p><a href="${env.BUILD_URL}console">Voir les logs du build</a></p>
                """,
                to: 'ousinfaye4@gmail.com',
                mimeType: 'text/html'
            )
        }
    }
}
```

#### Étape 3 : Save et Build

1. Cliquez sur **Save**
2. Cliquez sur **Build Now**

---

### Option 3 : Vérifier les Credentials GitHub

Le problème peut venir des credentials GitHub.

#### Vérifier les Credentials

1. **Manage Jenkins** > **Manage Credentials**
2. Cliquez sur **(global)**
3. Trouvez **github-credential**
4. Vérifiez que :
   - Username est correct
   - Password/Token est valide

#### Recréer les Credentials si Nécessaire

1. Supprimez l'ancien **github-credential**
2. **Add Credentials**
3. Kind: **Username with password**
4. Username: `dembouz7`
5. Password: [Votre Personal Access Token GitHub]
6. ID: `github-credential`
7. Description: `Github Credential`
8. **Create**

#### Créer un Personal Access Token GitHub

Si vous n'avez pas de token :

1. Allez sur https://github.com/settings/tokens
2. **Generate new token** > **Generate new token (classic)**
3. Note: `Jenkins CI/CD`
4. Expiration: `No expiration` (ou 90 days)
5. Scopes: ✅ **repo** (tous les sous-scopes)
6. **Generate token**
7. Copiez le token (vous ne le verrez qu'une fois !)
8. Utilisez ce token comme password dans Jenkins

---

### Option 4 : Utiliser Repository Local (TEMPORAIRE)

Pour tester rapidement, utilisez le repository local :

#### Configuration

1. Projet > **Configure**
2. Pipeline > Repository URL: `file:///c/laragon/www/projet_fil_rouge`
3. Credentials: **- none -**
4. **Save**
5. **Build Now**

**Note :** Cette option ne fonctionne que si Jenkins peut accéder au système de fichiers Windows, ce qui n'est pas le cas avec Docker.

---

## Recommandation

**Suivez l'Option 1 (Reconfigurer le Projet)** - C'est la solution la plus propre et la plus fiable.

Si l'Option 1 ne fonctionne pas, essayez **l'Option 2 (Pipeline Script Direct)** qui évite complètement le problème de SCM.

---

## Checklist de Vérification

Avant de relancer :

- ✅ Credentials Docker Hub existent (`dockerhub-credentials`)
- ✅ Credentials GitHub existent (`github-credential`)
- ✅ Email SMTP configuré
- ✅ Docker CLI installé dans Jenkins
- ✅ docker-compose installé dans Jenkins
- ✅ Repository GitHub accessible

---

## Commandes de Diagnostic

```bash
# Vérifier que Jenkins peut accéder à GitHub
docker exec jenkins git ls-remote https://github.com/dembouz07/projet_fil_rouge.git

# Vérifier Docker dans Jenkins
docker exec jenkins docker --version
docker exec jenkins docker-compose --version

# Voir les workspaces Jenkins
docker exec jenkins ls -la /var/jenkins_home/workspace/

# Nettoyer tous les workspaces (si nécessaire)
docker exec jenkins rm -rf /var/jenkins_home/workspace/*
```

---

## Prochaine Action

1. **Choisissez l'Option 1 ou 2**
2. **Suivez les étapes exactement**
3. **Lancez un build**
4. **Montrez-moi les logs**

Je vous recommande **l'Option 2 (Pipeline Script Direct)** car elle est plus simple et évite le problème de SCM.
