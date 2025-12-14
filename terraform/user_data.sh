#!/bin/bash
set -e

# Actualizar sistema
yum update -y

# Instalar Docker
yum install -y docker

# Iniciar Docker
service docker start
chkconfig docker on

# Permitir docker sin sudo
usermod -aG docker ec2-user

curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

curl -s -o docker-compose.yml https://raw.githubusercontent.com/AlexaD09/Pokeapi/main/docker-compose.yml


/usr/local/bin/docker-compose pull
/usr/local/bin/docker-compose up -d
