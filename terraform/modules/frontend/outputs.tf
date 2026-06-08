output "service_name" {
  description = "Nom du service Kubernetes frontend pour l'ingress"
  value       = kubernetes_service.frontend.metadata[0].name
}

output "service_port" {
  description = "Port du service frontend (Nginx)"
  value       = 80
}

output "deployment_name" {
  description = "Nom du déploiement Kubernetes du frontend"
  value       = kubernetes_deployment.frontend.metadata[0].name
}

output "replicas" {
  description = "Nombre de réplicas frontend déployés"
  value       = var.replicas
}
