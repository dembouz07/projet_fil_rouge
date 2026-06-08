# ===========================================
# TERRAFORM - Déploiement Kubernetes Portfolio
# ===========================================

# Namespace
module "namespace" {
  source    = "./modules/namespace"
  namespace = var.namespace
}

# MongoDB
module "mongodb" {
  source       = "./modules/mongodb"
  namespace    = module.namespace.name
  storage_size = var.mongodb_storage_size

  depends_on = [module.namespace]
}

# Backend
module "backend" {
  source      = "./modules/backend"
  namespace   = module.namespace.name
  image       = var.backend_image
  replicas    = var.backend_replicas
  mongodb_uri = "mongodb://${module.mongodb.username}:${module.mongodb.password}@${module.mongodb.service_name}:27017/portfolio?authSource=admin"

  depends_on = [module.mongodb]
}

# Frontend
module "frontend" {
  source      = "./modules/frontend"
  namespace   = module.namespace.name
  image       = var.frontend_image
  replicas    = var.frontend_replicas
  backend_url = "http://${var.ingress_host}/api"

  depends_on = [module.namespace]
}

# Ingress
module "ingress" {
  source           = "./modules/ingress"
  namespace        = module.namespace.name
  host             = var.ingress_host
  frontend_service = module.frontend.service_name
  backend_service  = module.backend.service_name

  depends_on = [module.frontend, module.backend]
}
