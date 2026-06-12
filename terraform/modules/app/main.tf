# ===========================================
# Module Application - Déploiement sur EKS
# ===========================================

# Namespace
resource "kubernetes_namespace" "portfolio" {
  metadata {
    name = var.namespace
    labels = {
      app     = "portfolio"
      managed = "terraform"
    }
  }
}

# MongoDB PVC
resource "kubernetes_persistent_volume_claim" "mongodb" {
  metadata {
    name      = "mongodb-pvc"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

# MongoDB Deployment
resource "kubernetes_deployment" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo:8.0-rc"

          port {
            container_port = 27017
          }

          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "admin"
          }

          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = "admin123"
          }

          volume_mount {
            name       = "mongodb-storage"
            mount_path = "/data/db"
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1000m"
            }
          }
        }

        volume {
          name = "mongodb-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb.metadata[0].name
          }
        }
      }
    }
  }
}

# MongoDB Service
resource "kubernetes_service" "mongodb" {
  metadata {
    name      = "mongodb-service"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    selector = {
      app = "mongodb"
    }

    port {
      port        = 27017
      target_port = 27017
    }

    type = "ClusterIP"
  }
}

# Backend Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    replicas = var.backend_replicas

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = var.backend_image

          port {
            container_port = 3001
          }

          env {
            name  = "MONGODB_URI"
            value = "mongodb://admin:admin123@mongodb-service:27017/portfolio?authSource=admin"
          }

          env {
            name  = "PORT"
            value = "3001"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3001
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3001
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.mongodb]
}

# Backend Service
resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      port        = 80
      target_port = 3001
    }

    type = "ClusterIP"
  }
}

# Frontend Deployment
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    replicas = var.frontend_replicas

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = var.frontend_image

          port {
            container_port = 80
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }
        }
      }
    }
  }
}

# Frontend Service (LoadBalancer pour accès externe)
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace.portfolio.metadata[0].name
  }

  spec {
    selector = {
      app = "frontend"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
