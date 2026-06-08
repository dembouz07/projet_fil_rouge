output "name" {
  description = "Nom du namespace Kubernetes créé pour le portfolio"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "id" {
  description = "ID unique du namespace"
  value       = kubernetes_namespace.this.id
}
