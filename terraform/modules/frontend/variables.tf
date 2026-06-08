variable "namespace" {
  description = "Namespace Kubernetes où déployer l'application frontend React"
  type        = string
}

variable "image" {
  description = "Image Docker du frontend React avec Nginx (ex: dembouz7/portfolio-frontend:latest)"
  type        = string
}

variable "replicas" {
  description = "Nombre de réplicas frontend pour répartir la charge utilisateur (minimum recommandé: 2)"
  type        = number
  default     = 2

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "Le nombre de réplicas doit être entre 1 et 10."
  }
}

variable "backend_url" {
  description = "URL complète de l'API backend pour les appels AJAX (ex: http://portfolio.local/api)"
  type        = string
}
