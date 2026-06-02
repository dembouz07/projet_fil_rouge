pipeline {
    agent any
    
    parameters {
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['docker-compose', 'kubernetes'],
            description: 'Choisir la cible de déploiement'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Ignorer les tests'
        )
    }
    
    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
    }
    
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
        timeout(time: 10, unit: 'MINUTES') {
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
        
        stage('Deploy to Docker Compose') {
            when {
                expression { params.DEPLOY_TARGET == 'docker-compose' }
            }
            steps {
                echo 'Deploying to Docker Compose...'
                script {
                    sh 'docker stop portfolio-mongodb portfolio-backend portfolio-frontend || true'
                    sh 'docker rm -f portfolio-mongodb portfolio-backend portfolio-frontend || true'
                    sh 'docker-compose -f docker-compose.hub.yml down -v || true'
                    sh 'docker-compose -f docker-compose.hub.yml pull'
                    sh 'docker-compose -f docker-compose.hub.yml up -d'
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Mettre à jour les images dans les deployments
                    sh """
                        kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${VERSION} -n portfolio || true
                        kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${VERSION} -n portfolio || true
                    """
                    
                    // Si les deployments n'existent pas, les créer
                    sh """
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/mongodb-deployment.yaml
                        kubectl apply -f k8s/backend-deployment.yaml
                        kubectl apply -f k8s/frontend-deployment.yaml
                        kubectl apply -f k8s/ingress.yaml
                    """
                    
                    // Attendre que les pods soient prêts
                    sh """
                        kubectl wait --for=condition=ready pod -l app=mongodb -n portfolio --timeout=300s
                        kubectl rollout status deployment/backend -n portfolio --timeout=300s
                        kubectl rollout status deployment/frontend -n portfolio --timeout=300s
                    """
                    
                    // Afficher l'état
                    sh 'kubectl get all -n portfolio'
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
                subject: "✅ Build réussi : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>✅ Build réussi</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Version:</strong> ${VERSION}</p>
                    <p><strong>Cible de déploiement:</strong> ${params.DEPLOY_TARGET}</p>
                    <p><strong>Statut:</strong> <span style="color: green;">SUCCÈS</span></p>
                    <hr>
                    <h3>Images Docker:</h3>
                    <ul>
                        <li><strong>Backend:</strong> ${BACKEND_IMAGE}:${VERSION}</li>
                        <li><strong>Frontend:</strong> ${FRONTEND_IMAGE}:${VERSION}</li>
                    </ul>
                    <hr>
                    <h3>Liens utiles:</h3>
                    <ul>
                        <li><a href="http://localhost:9000/dashboard?id=portfolio-cicd">Rapport SonarQube</a></li>
                        <li><a href="${env.BUILD_URL}">Détails du build Jenkins</a></li>
                        ${params.DEPLOY_TARGET == 'kubernetes' ? '<li><a href="http://portfolio.local">Application Kubernetes</a></li>' : '<li><a href="http://localhost:3000">Application Docker Compose</a></li>'}
                    </ul>
                """,
                to: 'ousinfaye4@gmail.com',
                mimeType: 'text/html'
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext(
                subject: "❌ Build échoué : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>❌ Build échoué</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Version:</strong> ${VERSION}</p>
                    <p><strong>Cible de déploiement:</strong> ${params.DEPLOY_TARGET}</p>
                    <p><strong>Statut:</strong> <span style="color: red;">ÉCHEC</span></p>
                    <hr>
                    <p><a href="${env.BUILD_URL}console">📋 Voir les logs du build</a></p>
                """,
                to: 'ousinfaye4@gmail.com',
                mimeType: 'text/html'
            )
        }
    }
}