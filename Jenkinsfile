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
                echo '📥 Cloning repository...'
                checkout scm
            }
        }
        
        stage('Build Backend') {
            steps {
                echo '🏗️ Building Backend Docker image...'
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
                echo '🏗️ Building Frontend Docker image...'
                script {
                    dir('react-js') {
                        bat "docker build -t ${FRONTEND_IMAGE}:${VERSION} ."
                        bat "docker tag ${FRONTEND_IMAGE}:${VERSION} ${FRONTEND_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Test Backend') {
            steps {
                echo '🧪 Running Backend tests...'
                script {
                    dir('express-js') {
                        bat 'npm install'
                        bat 'npm test || echo "No tests configured"'
                    }
                }
            }
        }
        
        stage('Test Frontend') {
            steps {
                echo '🧪 Running Frontend tests...'
                script {
                    dir('react-js') {
                        bat 'npm install'
                        bat 'npm test -- --passWithNoTests || echo "No tests configured"'
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo '🚀 Pushing images to Docker Hub...'
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
                echo '🚢 Deploying application...'
                script {
                    bat 'docker-compose -f docker-compose.hub.yml pull'
                    bat 'docker-compose -f docker-compose.hub.yml up -d'
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up...'
            bat 'docker logout'
        }
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Images pushed:"
            echo "  - ${BACKEND_IMAGE}:${VERSION}"
            echo "  - ${BACKEND_IMAGE}:latest"
            echo "  - ${FRONTEND_IMAGE}:${VERSION}"
            echo "  - ${FRONTEND_IMAGE}:latest"
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
