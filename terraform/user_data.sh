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

# Instalar docker-compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Crear carpeta de la app
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Descargar TU docker-compose.yml
curl -L https://raw.githubusercontent.com/AlexaD09/Pokeapi/main/docker-compose.yml \
  -o docker-compose.yml

# Quitar version (para compatibilidad)
sed -i '/^version:/d' docker-compose.yml

# Levantar contenedores
/usr/local/bin/docker-compose pull
/usr/local/bin/docker-compose up -d
