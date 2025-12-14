#!/bin/bash
# Install Docker and docker-compose
yum update -y
yum install -y docker curl
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Download docker and run the app
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app
curl -s -o docker-compose.yml https://raw.githubusercontent.com/AlexaD09/Pokeapi/main/docker-compose.yml


sed -i '/^version:/d' docker-compose.yml

# start the application
docker-compose pull
docker-compose up -d