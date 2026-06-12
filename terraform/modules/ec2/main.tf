# ===========================================
# Module EC2 - Instance de test
# ===========================================

# Récupérer l'AMI Amazon Linux 2023 la plus récente
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance EC2
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Mise à jour et installation Docker
              yum update -y
              yum install -y docker git
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              
              # Installer Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Installer kubectl
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              
              # Installer AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install
              rm -rf awscliv2.zip aws/
              
              # Cloner le projet et déployer l'application
              cd /home/ec2-user
              git clone https://github.com/dembouz07/projet_fil_rouge.git
              cd projet_fil_rouge
              
              # Créer docker-compose pour production
              cat > docker-compose.prod.yml <<'COMPOSE'
              version: '3.8'
              
              services:
                mongodb:
                  image: mongo:8.0-rc
                  container_name: portfolio-mongodb
                  restart: always
                  ports:
                    - "27017:27017"
                  environment:
                    MONGO_INITDB_ROOT_USERNAME: admin
                    MONGO_INITDB_ROOT_PASSWORD: admin123
                  volumes:
                    - mongodb_data:/data/db
              
                backend:
                  image: dembouz7/portfolio-backend:latest
                  container_name: portfolio-backend
                  restart: always
                  ports:
                    - "3001:3001"
                  environment:
                    MONGODB_URI: mongodb://admin:admin123@mongodb:27017/portfolio?authSource=admin
                    PORT: 3001
                  depends_on:
                    - mongodb
              
                frontend:
                  image: dembouz7/portfolio-frontend:latest
                  container_name: portfolio-frontend
                  restart: always
                  ports:
                    - "80:80"
                  depends_on:
                    - backend
              
              volumes:
                mongodb_data:
              COMPOSE
              
              # Démarrer l'application
              docker-compose -f docker-compose.prod.yml up -d
              
              # Changer les permissions
              chown -R ec2-user:ec2-user /home/ec2-user/projet_fil_rouge
              
              echo "✅ Instance EC2 configurée avec succès!" > /home/ec2-user/setup-complete.txt
              echo "✅ Application Portfolio déployée sur http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" >> /home/ec2-user/setup-complete.txt
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2"
  }
}
