# ===========================================
# Variables globales
# ===========================================

variable "aws_region" {
  description = "Région AWS pour le déploiement"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "portfolio"
}

# ===========================================
# Variables VPC
# ===========================================

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zones de disponibilité"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ===========================================
# Variables EC2
# ===========================================

variable "deploy_ec2" {
  description = "Déployer une instance EC2 de test"
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Nom de la clé SSH pour EC2"
  type        = string
  default     = ""
}

# ===========================================
# Variables EKS
# ===========================================

variable "deploy_eks" {
  description = "Déployer un cluster EKS"
  type        = bool
  default     = false
}

variable "eks_cluster_version" {
  description = "Version du cluster EKS"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Types d'instances pour les nodes EKS"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Nombre souhaité de nodes"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Nombre minimum de nodes"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Nombre maximum de nodes"
  type        = number
  default     = 3
}

# ===========================================
# Variables Application
# ===========================================

variable "backend_image" {
  description = "Image Docker du backend"
  type        = string
  default     = "dembouz7/portfolio-backend:latest"
}

variable "frontend_image" {
  description = "Image Docker du frontend"
  type        = string
  default     = "dembouz7/portfolio-frontend:latest"
}

variable "backend_replicas" {
  description = "Nombre de replicas backend"
  type        = number
  default     = 2
}

variable "frontend_replicas" {
  description = "Nombre de replicas frontend"
  type        = number
  default     = 2
}
