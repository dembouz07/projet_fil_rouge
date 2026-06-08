variable "namespace" {
  description = "Namespace Kubernetes pour le portfolio"
  type        = string
  default     = "portfolio"
}

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
  default     = 3
}

variable "frontend_replicas" {
  description = "Nombre de replicas frontend"
  type        = number
  default     = 2
}

variable "mongodb_storage_size" {
  description = "Taille du volume MongoDB"
  type        = string
  default     = "1Gi"
}

variable "ingress_host" {
  description = "Nom de domaine de l'ingress"
  type        = string
  default     = "portfolio.local"
}
