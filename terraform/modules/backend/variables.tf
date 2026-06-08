variable "namespace" {
  description = "Namespace Kubernetes où déployer l'API backend"
  type        = string
}

variable "image" {
  description = "Image Docker du backend Express.js (ex: dembouz7/portfolio-backend:latest)"
  type        = string
}

variable "replicas" {
  description = "Nombre de réplicas backend pour la haute disponibilité (minimum recommandé: 3)"
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "Le nombre de réplicas doit être entre 1 et 10."
  }
}

variable "mongodb_uri" {
  description = "URI de connexion complète à MongoDB avec authentification (mongodb://user:pass@host:port/db)"
  type        = string
  sensitive   = true
}
