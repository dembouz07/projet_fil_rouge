variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement"
  type        = string
}

variable "cluster_version" {
  description = "Version du cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs des subnets pour EKS"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Types d'instances pour les nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "Nombre souhaité de nodes"
  type        = number
}

variable "min_size" {
  description = "Nombre minimum de nodes"
  type        = number
}

variable "max_size" {
  description = "Nombre maximum de nodes"
  type        = number
}
