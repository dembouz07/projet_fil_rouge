variable "namespace" {
  description = "Namespace Kubernetes où déployer MongoDB"
  type        = string
}

variable "storage_size" {
  description = "Taille du volume de stockage persistant pour les données MongoDB (ex: 1Gi, 5Gi, 10Gi)"
  type        = string
  default     = "1Gi"

  validation {
    condition     = can(regex("^[0-9]+[MGT]i$", var.storage_size))
    error_message = "La taille du stockage doit être au format Kubernetes (ex: 1Gi, 500Mi, 2Ti)."
  }
}

variable "username" {
  description = "Nom d'utilisateur root MongoDB pour l'authentification"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Mot de passe root MongoDB (attention: ne pas committer en clair)"
  type        = string
  default     = "admin123"
  sensitive   = true
}
