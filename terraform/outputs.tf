# ===========================================
# Outputs VPC
# ===========================================

output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR du VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs des subnets privés"
  value       = module.vpc.private_subnet_ids
}

# ===========================================
# Outputs EC2
# ===========================================

output "ec2_public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = var.deploy_ec2 ? module.ec2[0].public_ip : null
}

output "ec2_connection_command" {
  description = "Commande SSH pour se connecter à l'instance EC2"
  value       = var.deploy_ec2 ? "ssh -i ${var.ec2_key_name}.pem ec2-user@${module.ec2[0].public_ip}" : null
}

# ===========================================
# Outputs EKS
# ===========================================

output "eks_cluster_name" {
  description = "Nom du cluster EKS"
  value       = var.deploy_eks ? module.eks[0].cluster_name : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = var.deploy_eks ? module.eks[0].cluster_endpoint : null
  sensitive   = true
}

output "eks_kubeconfig_command" {
  description = "Commande pour configurer kubectl"
  value       = var.deploy_eks ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks[0].cluster_name}" : null
}

# ===========================================
# Outputs Application
# ===========================================

output "application_url" {
  description = "URL de l'application (LoadBalancer)"
  value       = var.deploy_eks ? "Utilisez: kubectl get svc -n portfolio" : null
}
