output "namespace" {
  description = "Namespace de l'application"
  value       = kubernetes_namespace.portfolio.metadata[0].name
}

output "backend_service_name" {
  description = "Nom du service backend"
  value       = kubernetes_service.backend.metadata[0].name
}

output "frontend_service_name" {
  description = "Nom du service frontend"
  value       = kubernetes_service.frontend.metadata[0].name
}

output "mongodb_service_name" {
  description = "Nom du service MongoDB"
  value       = kubernetes_service.mongodb.metadata[0].name
}
