resource "kubernetes_ingress_v1" "portfolio" {
  metadata {
    name      = "portfolio-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = var.host

      http {
        # Route API vers Backend
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = var.backend_service
              port {
                number = 5000
              }
            }
          }
        }

        # Route Root vers Frontend
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.frontend_service
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
