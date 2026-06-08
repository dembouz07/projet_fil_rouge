resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace

    labels = {
      name        = var.namespace
      managed-by  = "terraform"
      environment = "development"
      project     = "portfolio-cicd"
      component   = "infrastructure"
    }

    annotations = {
      description = "Namespace pour l'application Portfolio - géré par Terraform"
      owner       = "DevOps Team"
    }
  }
}
