# ===========================================
# Infrastructure Terraform AWS
# Portfolio CI/CD Project
# ===========================================

# Module VPC - Réseau de base (toujours créé)
module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  single_nat_gateway  = true  # Utiliser 1 seul NAT Gateway (économie pour AWS Academy)
}

# Module EC2 - Instance de test (optionnel)
module "ec2" {
  count  = var.deploy_ec2 ? 1 : 0
  source = "./modules/ec2"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_ids[0]
  instance_type     = var.ec2_instance_type
  key_name          = var.ec2_key_name
  security_group_id = module.vpc.public_security_group_id
}

# Module EKS - Cluster Kubernetes (optionnel)
module "eks" {
  count  = var.deploy_eks ? 1 : 0
  source = "./modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  node_instance_types = var.eks_node_instance_types
  desired_size       = var.eks_node_desired_size
  min_size           = var.eks_node_min_size
  max_size           = var.eks_node_max_size
}

# Module Application sur EKS (si EKS déployé)
module "app_eks" {
  count  = var.deploy_eks ? 1 : 0
  source = "./modules/app"

  depends_on = [module.eks]

  namespace         = "portfolio"
  backend_image     = var.backend_image
  frontend_image    = var.frontend_image
  backend_replicas  = var.backend_replicas
  frontend_replicas = var.frontend_replicas
}
