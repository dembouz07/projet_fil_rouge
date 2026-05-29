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