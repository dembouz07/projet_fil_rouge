output "service_name" {
  description = "Nom du service Kubernetes MongoDB pour la connexion interne (DNS)"
  value       = kubernetes_service.mongodb.metadata[0].name
}

output "service_port" {
  description = "Port du service MongoDB"
  value       = 27017
}

output "connection_string" {
  description = "Chaîne de connexion MongoDB (sans authentification)"
  value       = "mongodb://${kubernetes_service.mongodb.metadata[0].name}:27017"
}

output "username" {
  description = "Nom d'utilisateur MongoDB root"
  value       = var.username
}

output "password" {
  description = "Mot de passe MongoDB root"
  value       = var.password
  sensitive   = true
}
