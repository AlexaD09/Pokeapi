#!/bin/bash
# Install Docker, curl, and AWS CLI
yum update -y
yum install -y docker curl aws-cli
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Prepare app directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Download docker-compose.yml from GitHub
curl -s -o docker-compose.yml https://raw.githubusercontent.com/Alexa1209/Pokeapi/main/docker-compose.yml
sed -i '/^version:/d' docker-compose.yml

# 👇 👇 👇 AGREGADO: Obtener DNS del ALB y guardar en .env 👇 👇 👇
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --names pokeapi-lb \
  --query 'LoadBalancers[0].DNSName' \
  --output text)

# Guardar en archivo .env (docker-compose lo lee automáticamente)
echo "ALB_DNS=$ALB_DNS" > .env
# 👆 👆 👆 FIN DE LO AGREGADO 👆 👆 👆

# Pull latest images and start containers
docker-compose pull
docker-compose up -d