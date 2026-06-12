# Terraform - Infrastructure as Code AWS

Ce dossier contient l'infrastructure Terraform pour déployer l'application Portfolio sur AWS.

## 📋 Contenu

- **VPC complet** avec subnets publics/privés, NAT Gateway, Internet Gateway
- **Instance EC2** optionnelle pour tests
- **Cluster EKS** optionnel (Amazon Elastic Kubernetes Service)
- **Application Portfolio** déployée sur EKS

## 🚀 Quick Start

### 1. Prérequis

```bash
# Installer Terraform
https://developer.hashicorp.com/terraform/install

# Installer AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# Configurer AWS credentials
aws configure
```

### 2. Initialiser Terraform

```bash
cd terraform
terraform init
```

### 3. Scénarios de déploiement

#### Scénario 1: VPC seulement (démo réseau)

```bash
terraform plan
terraform apply
```

#### Scénario 2: VPC + EC2 (test basique)

```bash
terraform apply -var="deploy_ec2=true" -var="ec2_key_name=your-key-name"
```

#### Scénario 3: VPC + EKS + Application (production)

```bash
terraform apply -var="deploy_eks=true"

# Configurer kubectl
aws eks update-kubeconfig --region us-east-1 --name portfolio-dev

# Vérifier les pods
kubectl get pods -n portfolio
```

## 📁 Structure

```
terraform/
├── main.tf              # Configuration principale
├── variables.tf         # Variables globales
├── outputs.tf           # Outputs
├── provider.tf          # Providers AWS et Kubernetes
└── modules/
    ├── vpc/             # Module VPC
    ├── ec2/             # Module EC2
    ├── eks/             # Module EKS
    └── app/             # Module Application K8s
```

## 🎯 Commandes essentielles

```bash
# Initialiser
terraform init

# Valider la configuration
terraform validate

# Prévisualiser les changements
terraform plan

# Appliquer les changements
terraform apply

# Détruire l'infrastructure
terraform destroy

# Afficher les outputs
terraform output

# Formater les fichiers
terraform fmt -recursive
```

## 🔧 Variables principales

| Variable | Description | Défaut |
|----------|-------------|--------|
| `aws_region` | Région AWS | `us-east-1` |
| `environment` | Environnement | `dev` |
| `deploy_ec2` | Déployer EC2 | `false` |
| `deploy_eks` | Déployer EKS | `false` |
| `ec2_key_name` | Clé SSH pour EC2 | `""` |
| `backend_image` | Image Docker backend | `dembouz7/portfolio-backend:latest` |
| `frontend_image` | Image Docker frontend | `dembouz7/portfolio-frontend:latest` |

## 📝 Exemple terraform.tfvars

```hcl
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "portfolio"

# Pour déployer EC2
deploy_ec2     = true
ec2_key_name   = "my-key"

# Pour déployer EKS
deploy_eks     = true
eks_node_desired_size = 2
eks_node_min_size     = 1
eks_node_max_size     = 3

# Images de l'application
backend_image  = "dembouz7/portfolio-backend:v1.0.1"
frontend_image = "dembouz7/portfolio-frontend:v1.0.1"
```

## 💰 Estimation des coûts (us-east-1)

| Ressource | Coût mensuel approximatif |
|-----------|---------------------------|
| VPC (NAT Gateway) | ~$32/mois |
| EC2 t3.micro | ~$7/mois |
| EKS Cluster | $73/mois |
| EKS Nodes (2x t3.medium) | ~$60/mois |
| **Total EKS** | **~$165/mois** |

⚠️ **Important**: Détruisez les ressources après les tests pour éviter les frais !

```bash
terraform destroy
```

## 🔐 Sécurité

- Credentials AWS via `aws configure` (jamais dans le code)
- State file contient des informations sensibles (ne pas commit)
- Security groups configurés avec règles minimales
- Encryption activée sur volumes EBS

## 📚 Liens utiles

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Guide de démonstration complet](./GUIDE_DEMO_TERRAFORM.md)
