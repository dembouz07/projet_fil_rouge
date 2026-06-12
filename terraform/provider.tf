terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Portfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Provider Kubernetes pour EKS
provider "kubernetes" {
  host                   = try(module.eks[0].cluster_endpoint, "")
  cluster_ca_certificate = try(base64decode(module.eks[0].cluster_ca_certificate), "")
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      try(module.eks[0].cluster_name, "")
    ]
  }
}
