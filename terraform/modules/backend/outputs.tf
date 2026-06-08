output "service_name" {
  description = "Nom du service Kubernetes backend pour la connexion interne"
  value       = kubernetes_service.backend.metadata[0].name
}

output "service_port" {
  description = "Port du service backend (API REST)"
  value       = 5000
}

output "deployment_name" {
  description = "Nom du déploiement Kubernetes du backend"
  value       = kubernetes_deployment.backend.metadata[0].name
}

output "replicas" {
  description = "Nombre de réplicas backend déployés"
  value       = var.replicas
}
