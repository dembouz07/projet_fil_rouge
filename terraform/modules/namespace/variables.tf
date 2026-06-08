variable "namespace" {
  description = "Nom du namespace Kubernetes pour isoler les ressources du portfolio"
  type        = string

  validation {
    condition     = length(var.namespace) > 0 && length(var.namespace) <= 63
    error_message = "Le nom du namespace doit contenir entre 1 et 63 caractères."
  }
}
