# Guide de Démonstration Terraform

## 6.1. Problématique (Pourquoi ?)

### Problèmes sans Infrastructure as Code (IaC):
- **Configuration manuelle** répétitive et sujette aux erreurs
- **Pas de traçabilité** des changements d'infrastructure
- **Documentation obsolète** rapidement
- **Difficile à répliquer** entre environnements (dev/staging/prod)
- **Pas de versioning** de l'infrastructure
- **Rollback complexe** en cas de problème

### Solutions avec Terraform:
✅ Infrastructure définie en code (versionnée avec Git)  
✅ Déploiements reproductibles et automatisés  
✅ Documentation vivante (le code EST la documentation)  
✅ Preview des changements avant application  
✅ Destruction facile de l'infrastructure  
✅ Réutilisation via modules  

---

## 6.2. Présentation (Quoi ?)

**Terraform** est un outil open-source d'Infrastructure as Code (IaC) développé par HashiCorp.

### Caractéristiques:
- **Déclaratif**: Vous décrivez l'état désiré, Terraform gère le "comment"
- **Multi-cloud**: AWS, Azure, GCP, Kubernetes, etc.
- **Plan/Apply**: Prévisualisation avant modification
- **State management**: Suivi de l'infrastructure actuelle

### Cas d'usage:
- Provisionner infrastructure cloud (VPC, EC2, RDS, etc.)
- Gérer clusters Kubernetes (EKS, GKE, AKS)
- Configurer services DNS, CDN, monitoring
- Déployer applications sur Kubernetes

---

## 6.3. Concepts Fondamentaux

### 1. **Providers**
Plugins pour interagir avec les APIs de services cloud.

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host = aws_eks_cluster.main.endpoint
}
```

### 2. **Resources**
Éléments d'infrastructure à créer.

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "my-vpc"
  }
}
```

### 3. **Data Sources**
Récupérer des informations existantes.

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}
```

### 4. **Variables**
Paramètres configurables.

```hcl
variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

# Utilisation
resource "aws_instance" "web" {
  instance_type = var.instance_type
}
```

### 5. **Outputs**
Valeurs à afficher après déploiement.

```hcl
output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}
```

### 6. **Modules**
Regrouper des ressources réutilisables.

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
  environment = "production"
}
```

### 7. **State**
Fichier qui stocke l'état actuel de l'infrastructure.

```bash
# Fichier: terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.6.0",
  "resources": [...]
}
```

⚠️ **Ne jamais commiter le state file** (contient des données sensibles)

---

## 6.4. Architecture

### Architecture du Projet

```
┌─────────────────────────────────────────────────────┐
│                    AWS Account                       │
│                                                       │
│  ┌─────────────────────────────────────────────┐   │
│  │              VPC (10.0.0.0/16)               │   │
│  │                                               │   │
│  │  ┌─────────────────┐  ┌──────────────────┐ │   │
│  │  │  Public Subnets │  │  Private Subnets  │ │   │
│  │  │                  │  │                   │ │   │
│  │  │  - EC2 (test)   │  │  - EKS Nodes      │ │   │
│  │  │  - NAT Gateway  │  │  - Application    │ │   │
│  │  │  - Internet GW  │  │                   │ │   │
│  │  └─────────────────┘  └──────────────────┘ │   │
│  │                                               │   │
│  │  ┌──────────────────────────────────────┐  │   │
│  │  │        EKS Cluster (optionnel)        │  │   │
│  │  │                                        │  │   │
│  │  │  ┌──────────┐  ┌─────────┐  ┌──────┐│  │   │
│  │  │  │ MongoDB  │  │ Backend │  │ Front││  │   │
│  │  │  │   Pod    │  │  Pods   │  │ Pods ││  │   │
│  │  │  └──────────┘  └─────────┘  └──────┘│  │   │
│  │  │                                        │  │   │
│  │  │       LoadBalancer (accès externe)    │  │   │
│  │  └──────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Flux de données:
1. **Internet** → Internet Gateway → Public Subnets
2. **Private Subnets** → NAT Gateway → Internet Gateway → Internet
3. **EKS Nodes** dans Private Subnets (sécurisé)
4. **Application** exposée via LoadBalancer AWS

---

## 6.5. Fichiers de Configuration

### Structure des fichiers:

```
terraform/
├── provider.tf          # Configuration des providers
├── variables.tf         # Définition des variables
├── main.tf              # Configuration principale (modules)
├── outputs.tf           # Outputs globaux
├── .gitignore           # Fichiers à ignorer
├── terraform.tfvars     # Valeurs des variables (NE PAS COMMIT)
│
└── modules/
    ├── vpc/             # Module réseau
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2/             # Module instance de test
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── eks/             # Module cluster Kubernetes
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── app/             # Module application K8s
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### Ordre de lecture des fichiers:
1. `provider.tf` - Configuration providers
2. `variables.tf` - Variables disponibles
3. `main.tf` - Ressources/modules à créer
4. `outputs.tf` - Valeurs à afficher

---

## 6.6. Commandes de Base

### Commandes essentielles:

```bash
# 1. Initialiser (télécharge les providers)
terraform init

# 2. Formater le code
terraform fmt -recursive

# 3. Valider la syntaxe
terraform validate

# 4. Planifier les changements (DRY RUN)
terraform plan

# 5. Appliquer les changements
terraform apply

# 6. Appliquer sans confirmation
terraform apply -auto-approve

# 7. Détruire l'infrastructure
terraform destroy

# 8. Afficher les outputs
terraform output

# 9. Afficher le state
terraform show

# 10. Rafraîchir le state
terraform refresh
```

### Commandes avancées:

```bash
# Appliquer avec variables
terraform apply -var="deploy_eks=true" -var="environment=prod"

# Cibler une ressource spécifique
terraform apply -target=module.vpc

# Détruire une ressource spécifique
terraform destroy -target=module.ec2

# Importer ressource existante
terraform import aws_vpc.main vpc-12345678

# Lister les ressources du state
terraform state list

# Voir une ressource du state
terraform state show aws_vpc.main
```

---

## 6.7. Installation

### Windows (PowerShell):

```powershell
# Télécharger Terraform
Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_windows_amd64.zip -OutFile terraform.zip

# Extraire
Expand-Archive terraform.zip -DestinationPath C:\terraform

# Ajouter au PATH
$env:Path += ";C:\terraform"

# Vérifier
terraform version
```

### Linux / Jenkins:

```bash
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version
```

### AWS CLI Installation:

```bash
# Windows
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurer credentials
aws configure
```

---

## 6.8. Demo - Pratique

### 📝 Demo 1: Créer un VPC et une instance EC2

#### Étape 1: Préparer les credentials AWS

```bash
# Configurer AWS CLI
aws configure
# AWS Access Key ID: AKIAXXXXXXXXXXXXXXXX
# AWS Secret Access Key: ********
# Default region: us-east-1
# Default output format: json

# Créer une clé SSH (si nécessaire)
aws ec2 create-key-pair --key-name my-terraform-key --query 'KeyMaterial' --output text > my-terraform-key.pem
chmod 400 my-terraform-key.pem
```

#### Étape 2: Configuration Terraform

```bash
cd terraform

# Créer fichier terraform.tfvars
cat > terraform.tfvars << EOF
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "portfolio"

# Déployer VPC + EC2
deploy_ec2     = true
ec2_key_name   = "my-terraform-key"
ec2_instance_type = "t3.micro"

# NE PAS déployer EKS (trop cher pour démo)
deploy_eks     = false
EOF
```

#### Étape 3: Déployer

```bash
# Initialiser
terraform init

# Voir le plan
terraform plan

# Appliquer
terraform apply

# Observer les outputs
terraform output
```

#### Résultat attendu:

```
Outputs:

vpc_id = "vpc-0a1b2c3d4e5f6g7h8"
vpc_cidr = "10.0.0.0/16"
public_subnet_ids = [
  "subnet-0123456789abcdef0",
  "subnet-0123456789abcdef1",
]
ec2_public_ip = "3.80.123.45"
ec2_connection_command = "ssh -i my-terraform-key.pem ec2-user@3.80.123.45"
```

#### Étape 4: Se connecter à l'instance

```bash
# Utiliser la commande output
ssh -i my-terraform-key.pem ec2-user@3.80.123.45

# Vérifier les installations
docker --version
kubectl version --client
aws --version
```

#### Étape 5: Nettoyer

```bash
# Détruire toute l'infrastructure
terraform destroy
```

**💰 Coût de la démo 1: ~$0.01/heure (VPC NAT + EC2 t3.micro)**

---

### 📝 Demo 2: Déployer l'application sur EKS

#### Étape 1: Configuration pour EKS

```bash
# Créer terraform.tfvars pour EKS
cat > terraform.tfvars << EOF
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "portfolio"

# Déployer EKS
deploy_eks     = true
eks_cluster_version = "1.28"
eks_node_desired_size = 2
eks_node_min_size     = 1
eks_node_max_size     = 3
eks_node_instance_types = ["t3.medium"]

# Images de l'application
backend_image  = "dembouz7/portfolio-backend:latest"
frontend_image = "dembouz7/portfolio-frontend:latest"
backend_replicas  = 2
frontend_replicas = 2
EOF
```

#### Étape 2: Déployer EKS

```bash
# Initialiser
terraform init

# Planifier (15-20 min pour créer EKS)
terraform plan

# Appliquer
terraform apply

# ⏰ Attendre 15-20 minutes...
```

#### Étape 3: Configurer kubectl

```bash
# Récupérer la commande depuis output
terraform output eks_kubeconfig_command

# Exécuter la commande
aws eks update-kubeconfig --region us-east-1 --name portfolio-dev

# Vérifier la connexion
kubectl get nodes
kubectl get pods -n portfolio
```

#### Résultat attendu:

```bash
$ kubectl get nodes
NAME                             STATUS   ROLES    AGE   VERSION
ip-10-0-3-123.ec2.internal       Ready    <none>   5m    v1.28.0
ip-10-0-4-45.ec2.internal        Ready    <none>   5m    v1.28.0

$ kubectl get pods -n portfolio
NAME                        READY   STATUS    RESTARTS   AGE
mongodb-xxx                 1/1     Running   0          3m
backend-xxx                 1/1     Running   0          2m
backend-yyy                 1/1     Running   0          2m
frontend-xxx                1/1     Running   0          2m
frontend-yyy                1/1     Running   0          2m
```

#### Étape 4: Accéder à l'application

```bash
# Obtenir l'URL du LoadBalancer
kubectl get svc -n portfolio

# Output:
# NAME               TYPE           EXTERNAL-IP                                    PORT
# frontend-service   LoadBalancer   a1b2c3d4e5f6g7h8.us-east-1.elb.amazonaws.com   80

# Ouvrir dans le navigateur
# http://a1b2c3d4e5f6g7h8.us-east-1.elb.amazonaws.com
```

#### Étape 5: Tester le scaling

```bash
# Modifier variables.tf ou terraform.tfvars
# backend_replicas = 3
# frontend_replicas = 3

# Appliquer les changements
terraform apply

# Vérifier
kubectl get pods -n portfolio
```

#### Étape 6: Nettoyer (IMPORTANT!)

```bash
# Détruire tout pour éviter les frais
terraform destroy

# ⏰ Attendre 10-15 minutes...
```

**💰 Coût de la démo 2: ~$0.15/heure (EKS + 2 nodes t3.medium + NAT)**

---

### 📝 Demo 3: Intégration avec Jenkins

Voir le fichier `Jenkinsfile` qui contient le stage Terraform:

```groovy
stage('Deploy with Terraform') {
    when {
        expression { params.DEPLOY_TARGET == 'terraform' }
    }
    steps {
        script {
            dir('terraform') {
                // Installer Terraform
                sh 'terraform init'
                
                // Créer tfvars avec images à jour
                sh """
                    cat > terraform.auto.tfvars <<EOF
deploy_eks = true
backend_image = "${BACKEND_IMAGE}:${VERSION}"
frontend_image = "${FRONTEND_IMAGE}:${VERSION}"
EOF
                """
                
                // Appliquer
                sh 'terraform apply -auto-approve'
            }
        }
    }
}
```

**Configuration requise dans Jenkins:**
1. Credentials AWS (Access Key + Secret Key)
2. Terraform installé dans le conteneur Jenkins
3. AWS CLI configuré

---

## 6.9. Références

### Documentation officielle:
- **Terraform**: https://developer.hashicorp.com/terraform/docs
- **AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Kubernetes Provider**: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs

### Tutorials:
- **Terraform Get Started**: https://developer.hashicorp.com/terraform/tutorials/aws-get-started
- **AWS EKS Guide**: https://docs.aws.amazon.com/eks/latest/userguide/
- **Terraform Best Practices**: https://www.terraform-best-practices.com/

### Modules communautaires:
- **Terraform AWS Modules**: https://github.com/terraform-aws-modules
- **VPC Module**: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
- **EKS Module**: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws

### Outils:
- **Terraform Cloud**: https://app.terraform.io (state management gratuit)
- **Infracost**: https://www.infracost.io/ (estimation des coûts)
- **tfsec**: https://github.com/aquasecurity/tfsec (sécurité)
- **terraform-docs**: https://terraform-docs.io/ (génération documentation)

### Communauté:
- **HashiCorp Discuss**: https://discuss.hashicorp.com/c/terraform-core
- **Reddit r/terraform**: https://www.reddit.com/r/Terraform/
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/terraform

---

## ✅ Checklist de Démonstration

### Préparation:
- [ ] AWS Account configuré
- [ ] AWS CLI installé et configuré (`aws configure`)
- [ ] Terraform installé (`terraform version`)
- [ ] kubectl installé (pour démo EKS)
- [ ] Budget alert configuré sur AWS (éviter les surprises!)

### Demo VPC + EC2:
- [ ] `terraform init`
- [ ] `terraform validate`
- [ ] `terraform plan` (expliquer le plan)
- [ ] `terraform apply`
- [ ] SSH vers l'instance EC2
- [ ] `terraform output` (montrer les valeurs)
- [ ] `terraform destroy`

### Demo EKS:
- [ ] Modifier `deploy_eks = true`
- [ ] `terraform apply` (attendre 15-20 min)
- [ ] Configurer kubectl avec EKS
- [ ] `kubectl get nodes`
- [ ] `kubectl get pods -n portfolio`
- [ ] Accéder au LoadBalancer
- [ ] **IMPORTANT: `terraform destroy`** (éviter les frais!)

### Points à mentionner:
- Concept d'Infrastructure as Code
- Avantage du state file
- Preview avec `plan` avant `apply`
- Modules réutilisables
- Multi-environnement (dev/staging/prod)
- Intégration CI/CD avec Jenkins

---

## ⚠️ Notes Importantes

### Sécurité:
- **Ne jamais commiter** `terraform.tfstate` ou `terraform.tfvars`
- Utiliser **AWS Secrets Manager** pour données sensibles
- **Backend S3** pour state en production (pas local)
- **DynamoDB locking** pour éviter conflits

### Coûts:
- **NAT Gateway**: ~$32/mois (même idle!)
- **EKS Control Plane**: $73/mois
- **EC2 Instances**: selon le type
- **LoadBalancer**: ~$16/mois
- **⚠️ Toujours détruire après démo!**

### Best Practices:
- Utiliser des **modules** pour réutilisation
- **Commenter** le code complexe
- **Versionner** avec Git
- Utiliser **remote backend** (S3 + DynamoDB)
- Séparer **variables** par environnement
- Activer **logs CloudWatch** pour debugging

---

**🎉 Bonne démonstration Terraform!**
