output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Adresse IP publique"
  value       = aws_instance.main.public_ip
}

output "public_dns" {
  description = "DNS public"
  value       = aws_instance.main.public_dns
}

output "application_url" {
  description = "URL de l'application Portfolio"
  value       = "http://${aws_instance.main.public_ip}"
}
