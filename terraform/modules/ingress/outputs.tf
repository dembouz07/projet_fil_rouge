output "ingress_name" {
  description = "Nom de la ressource Ingress Kubernetes"
  value       = kubernetes_ingress_v1.portfolio.metadata[0].name
}

output "ingress_host" {
  description = "Nom de domaine configuré pour accéder à l'application"
  value       = var.host
}

output "application_url" {
  description = "URL complète de l'application"
  value       = "http://${var.host}"
}

output "api_url" {
  description = "URL de l'API backend"
  value       = "http://${var.host}/api"
}
