# ===========================================
# Module MongoDB - Base de données persistante
# ===========================================

# PersistentVolumeClaim pour la persistance des données
resource "kubernetes_persistent_volume_claim" "mongodb" {
  metadata {
    name      = "mongodb-pvc"
    namespace = var.namespace

    labels = {
      app       = "mongodb"
      component = "database"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

# Deployment MongoDB
resource "kubernetes_deployment" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = var.namespace

    labels = {
      app       = "mongodb"
      component = "database"
      version   = "8.0-rc"
    }
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
          app       = "mongodb"
          component = "database"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo:8.0-rc"

          port {
            name           = "mongodb"
            container_port = 27017
            protocol       = "TCP"
          }

          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = var.username
          }

          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = var.password
          }

          volume_mount {
            name       = "mongodb-storage"
            mount_path = "/data/db"
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
            exec {
              command = ["mongosh", "--eval", "db.adminCommand('ping')"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["mongosh", "--eval", "db.adminCommand('ping')"]
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
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

# Service MongoDB pour la communication interne
resource "kubernetes_service" "mongodb" {
  metadata {
    name      = "mongodb-service"
    namespace = var.namespace

    labels = {
      app       = "mongodb"
      component = "database"
    }
  }

  spec {
    selector = {
      app = "mongodb"
    }

    port {
      name        = "mongodb"
      port        = 27017
      target_port = 27017
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
