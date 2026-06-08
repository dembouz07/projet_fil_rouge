variable "namespace" {
  description = "Namespace Kubernetes où créer l'ingress"
  type        = string
}

variable "host" {
  description = "Nom de domaine pour accéder à l'application (ex: portfolio.local, portfolio.example.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.host))
    error_message = "Le hostname doit être un nom de domaine valide."
  }
}

variable "frontend_service" {
  description = "Nom du service Kubernetes frontend à router (généré par le module frontend)"
  type        = string
}

variable "backend_service" {
  description = "Nom du service Kubernetes backend à router (généré par le module backend)"
  type        = string
}
