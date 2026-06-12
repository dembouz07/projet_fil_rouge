# Nettoyage Infrastructure Partielle

## Contexte
Le déploiement Terraform a créé le VPC et les subnets mais a échoué sur la création des rôles IAM EKS.
Nous devons détruire ces ressources avant de relancer avec la configuration EC2.

## Option 1: Depuis Jenkins (RECOMMANDÉ)

1. Relancer le build avec `TERRAFORM_DESTROY = true`
2. Attendre que les ressources soient détruites
3. Relancer le build avec `TERRAFORM_DESTROY = false` pour déployer VPC+EC2

## Option 2: Manuellement depuis votre machine

```bash
cd terraform
terraform destroy -auto-approve
```

## Ressources à détruire
- VPC: vpc-08a586843a2d90027
- NAT Gateways: nat-0165f1c52aefb110c, nat-07ba41114a7c38470
- Elastic IPs: eipalloc-0657b5e474e3f10ce, eipalloc-0bda1cab0e52881f4
- Subnets publics et privés
- Route tables
- Internet Gateway
- Security groups
