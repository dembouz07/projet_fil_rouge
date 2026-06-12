variable "namespace" {
  description = "Namespace Kubernetes"
  type        = string
}

variable "backend_image" {
  description = "Image Docker du backend"
  type        = string
}

variable "frontend_image" {
  description = "Image Docker du frontend"
  type        = string
}

variable "backend_replicas" {
  description = "Nombre de replicas backend"
  type        = number
}

variable "frontend_replicas" {
  description = "Nombre de replicas frontend"
  type        = number
}
