pipeline {
    agent any
    
    parameters {
        choice(
            name: 'DEPLOY_TARGET',
            choices: ['terraform', 'docker-compose', 'kubernetes'],
            description: 'Choisir la cible de déploiement (terraform = AWS EKS)'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Ignorer les tests'
        )
        booleanParam(
            name: 'TERRAFORM_DESTROY',
            defaultValue: false,
            description: 'Détruire l\'infrastructure Terraform avant de la recréer'
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
            when {
                expression { !params.SKIP_TESTS }
            }
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
            when {
                expression { !params.SKIP_TESTS }
            }
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
                        sh "docker build --network=host -t ${BACKEND_IMAGE}:${VERSION} ."
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
                        sh "docker build --network=host -t ${FRONTEND_IMAGE}:${VERSION} ."
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
        
        // NOTE: Docker Compose commenté - Kubernetes local + AWS EKS via Terraform actifs
        
        stage('Deploy to Kubernetes') {
            when {
                expression { params.DEPLOY_TARGET == 'kubernetes' }
            }
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    // Installer kubectl si non présent
                    sh '''
                        if ! command -v kubectl &> /dev/null; then
                            curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl"
                            chmod +x kubectl
                            mv kubectl /usr/local/bin/ || sudo mv kubectl /usr/local/bin/
                        fi
                    '''
                    
                    // Créer/mettre à jour les ressources
                    sh """
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/mongodb-deployment.yaml
                        kubectl apply -f k8s/backend-deployment.yaml
                        kubectl apply -f k8s/frontend-deployment.yaml
                        kubectl apply -f k8s/ingress.yaml
                    """
                    
                    // Mettre à jour les images avec la version du build
                    sh """
                        kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${VERSION} -n portfolio || true
                        kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${VERSION} -n portfolio || true
                    """
                    
                    // Attendre que les pods soient prêts
                    sh """
                        kubectl wait --for=condition=ready pod -l app=mongodb -n portfolio --timeout=300s || true
                        kubectl rollout status deployment/backend -n portfolio --timeout=300s
                        kubectl rollout status deployment/frontend -n portfolio --timeout=300s
                    """
                    
                    // Afficher l'état
                    sh 'kubectl get all -n portfolio'
                    sh 'kubectl get ingress -n portfolio'
                    
                    // Récupérer l'URL du frontend à surveiller
                    def ingressHost = sh(
                        script: "kubectl get ingress portfolio-ingress -n portfolio -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || true",
                        returnStdout: true
                    ).trim()
                    def ingressAddr = sh(
                        script: "kubectl get ingress portfolio-ingress -n portfolio -o jsonpath='{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true",
                        returnStdout: true
                    ).trim()
                    
                    env.FRONTEND_URL = ingressHost ? "http://${ingressHost}" : "http://portfolio.local"
                    env.FRONTEND_INGRESS_ADDR = ingressAddr
                    echo "Frontend à surveiller : ${env.FRONTEND_URL} (ingress: ${ingressAddr})"
                }
            }
        }
        
        stage('Deploy to AWS EKS with Terraform') {
            when {
                expression { params.DEPLOY_TARGET == 'terraform' }
            }
            steps {
                echo '🚀 Deploying to AWS EKS with Terraform...'
                script {
                    // Charger les credentials AWS depuis Jenkins
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: 'aws-session-token', variable: 'AWS_SESSION_TOKEN')
                    ]) {
                        dir('terraform') {
                            // Installer Terraform si non présent
                            sh '''
                                if ! command -v terraform &> /dev/null; then
                                    curl -LO https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
                                    unzip terraform_1.6.6_linux_amd64.zip
                                    mv terraform /usr/local/bin/ || sudo mv terraform /usr/local/bin/
                                    rm terraform_1.6.6_linux_amd64.zip
                                fi
                            '''
                            
                            // Vérifier AWS CLI (normalement déjà installé)
                            sh 'aws --version'
                            
                            // Vérifier AWS credentials
                            sh 'aws sts get-caller-identity'
                            
                            // Vérifier la version de Terraform
                            sh 'terraform version'
                        
                            // Initialiser Terraform
                            sh 'terraform init'
                            
                            // Détruire l'infrastructure existante si demandé OU si déploiement échoué
                            if (params.TERRAFORM_DESTROY) {
                                echo 'Destroying existing infrastructure...'
                                sh 'terraform destroy -auto-approve'
                                sleep 10
                            } else {
                                // Import automatique des ressources orphelines si elles existent
                                echo 'Checking for existing resources...'
                                sh '''
                                    # Importer l'instance EC2 si elle existe (ignorer l'erreur si elle n'existe pas)
                                    aws ec2 describe-instances --filters "Name=tag:Name,Values=portfolio-dev-ec2" \
                                        "Name=instance-state-name,Values=running,stopped" \
                                        --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null | grep '^i-' && \
                                    terraform import 'module.ec2[0].aws_instance.main' $(aws ec2 describe-instances --filters "Name=tag:Name,Values=portfolio-dev-ec2" --query 'Reservations[0].Instances[0].InstanceId' --output text) || echo "No EC2 instance to import"
                                    
                                    # Supprimer les Elastic IPs orphelines qui bloquent
                                    echo "Cleaning up orphaned Elastic IPs..."
                                    for eip in $(aws ec2 describe-addresses --filters "Name=tag:Name,Values=portfolio-dev-nat-eip-*" --query 'Addresses[*].AllocationId' --output text); do
                                        echo "Releasing Elastic IP: $eip"
                                        aws ec2 release-address --allocation-id $eip || true
                                    done
                                    
                                    echo "Resource cleanup completed"
                                '''
                            }
                            
                            // Valider la configuration
                            sh 'terraform validate'
                            
                            // Créer un fichier tfvars avec les configurations
                            sh """
                            cat > terraform.auto.tfvars <<EOF
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "portfolio"

# Déployer EC2 uniquement (AWS Academy ne permet pas EKS)
deploy_eks     = false
deploy_ec2     = true

# Configuration EC2
ec2_instance_type = "t2.micro"
ec2_instance_count = 1

# Images de l'application (pour référence future)
backend_image  = "${BACKEND_IMAGE}:${VERSION}"
frontend_image = "${FRONTEND_IMAGE}:${VERSION}"
backend_replicas  = 2
frontend_replicas = 2
EOF
                            """
                            
                            // Afficher le plan
                            sh 'terraform plan -out=tfplan'
                            
                            // Appliquer les changements
                            sh 'terraform apply -auto-approve tfplan'
                            
                            // Afficher les outputs
                            sh 'terraform output'
                            
                            // Configurer kubectl pour EKS
                            sh '''
                                if [ -n "$(terraform output -raw eks_cluster_name 2>/dev/null)" ]; then
                                    aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw eks_cluster_name)
                                    kubectl get nodes
                                    kubectl get pods -n portfolio
                                    kubectl get svc -n portfolio
                                fi
                            '''
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up....'
            sh 'docker logout'
        }
        success {
            echo 'Pipeline completed successfully!'
            emailext(
                subject: "✅ Build réussi : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                body: """
                    <h2>✅ Build réussi Good Job</h2>
                    <p><strong>Projet:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Version:</strong> ${VERSION}</p>
                    <p><strong>Cible de déploiement:</strong> ${params.DEPLOY_TARGET}</p>
                    ${params.DEPLOY_TARGET == 'terraform' ? '<p><strong>Terraform Destroy:</strong> ' + params.TERRAFORM_DESTROY + '</p>' : ''}
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
                        ${params.DEPLOY_TARGET == 'terraform' ? '<li>Application déployée sur AWS EKS - Voir logs pour LoadBalancer URL</li>' : ''}
                        ${params.DEPLOY_TARGET == 'docker-compose' ? '<li><a href="http://localhost:3000">Application Docker Compose</a></li>' : ''}
                    </ul>
                    ${params.DEPLOY_TARGET == 'kubernetes' ? """
                    <hr>
                    <h3>🖥️ Application Frontend à surveiller</h3>
                    <p>Le déploiement Kubernetes est terminé. Surveillez l'application frontend à l'URL suivante :</p>
                    <p style="font-size: 16px;"><strong><a href="${env.FRONTEND_URL}">${env.FRONTEND_URL}</a></strong></p>
                    <ul>
                        <li><strong>URL Frontend:</strong> ${env.FRONTEND_URL}</li>
                        <li><strong>Adresse Ingress:</strong> ${env.FRONTEND_INGRESS_ADDR ?: 'N/A (ajouter portfolio.local dans /etc/hosts)'}</li>
                        <li><strong>Namespace:</strong> portfolio</li>
                    </ul>
                    <p>👉 Ajoutez cette URL comme cible dans Prometheus/Blackbox Exporter pour la supervision.</p>
                    """ : ''}
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
