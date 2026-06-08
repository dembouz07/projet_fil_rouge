# Terraform - Déploiement Kubernetes Portfolio

## 🚀 Quick Start

```powershell
# 1. Installer Terraform
choco install terraform

# 2. Vérifier l'installation
terraform version

# 3. Initialiser Terraform
terraform init

# 4. Voir le plan de déploiement
terraform plan

# 5. Déployer l'infrastructure
terraform apply

# 6. Supprimer l'infrastructure
terraform destroy
```

## 📁 Structure

```
terraform/
├── provider.tf          # Configuration du provider Kubernetes
├── variables.tf         # Variables configurables
├── main.tf             # Configuration principale
├── outputs.tf          # Valeurs de sortie
├── modules/            # Modules réutilisables
│   ├── namespace/
│   ├── mongodb/
│   ├── backend/
│   ├── frontend/
│   └── ingress/
└── GUIDE_DEMO_TERRAFORM.md  # Guide complet
```

## 📖 Documentation

Voir [GUIDE_DEMO_TERRAFORM.md](./GUIDE_DEMO_TERRAFORM.md) pour:
- Concepts Terraform
- Architecture détaillée
- Exemples de code
- Commandes complètes
- Références

## ⚙️ Variables

| Variable | Description | Défaut |
|----------|-------------|--------|
| `namespace` | Namespace Kubernetes | `portfolio` |
| `backend_image` | Image Docker backend | `dembouz7/portfolio-backend:latest` |
| `frontend_image` | Image Docker frontend | `dembouz7/portfolio-frontend:latest` |
| `backend_replicas` | Nombre de pods backend | `3` |
| `frontend_replicas` | Nombre de pods frontend | `2` |
| `mongodb_storage_size` | Taille volume MongoDB | `1Gi` |
| `ingress_host` | Domaine de l'application | `portfolio.local` |

## 🔧 Personnalisation

Créer un fichier `terraform.tfvars`:

```hcl
backend_replicas = 5
frontend_replicas = 4
ingress_host = "mon-portfolio.local"
```

## 📊 Outputs

Après `terraform apply`, voir les outputs:

```powershell
terraform output
terraform output application_url
```
