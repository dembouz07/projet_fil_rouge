variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
}

variable "availability_zones" {
  description = "Liste des zones de disponibilité"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Utiliser un seul NAT Gateway au lieu de un par AZ (économie de coûts)"
  type        = bool
  default     = false
}
