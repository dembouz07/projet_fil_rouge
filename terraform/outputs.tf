output "namespace" {
  description = "Namespace déployé"
  value       = module.namespace.name
}

output "mongodb_service" {
  description = "Service MongoDB"
  value       = module.mongodb.service_name
}

output "backend_service" {
  description = "Service Backend"
  value       = module.backend.service_name
}

output "frontend_service" {
  description = "Service Frontend"
  value       = module.frontend.service_name
}

output "application_url" {
  description = "URL de l'application"
  value       = "http://${var.ingress_host}"
}

output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    namespace         = module.namespace.name
    backend_replicas  = var.backend_replicas
    frontend_replicas = var.frontend_replicas
    mongodb_storage   = var.mongodb_storage_size
    ingress_host      = var.ingress_host
  }
}
