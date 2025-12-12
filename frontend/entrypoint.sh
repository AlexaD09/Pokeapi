#!/bin/sh

# OBTENER IP PÚBLICA DE LA EC2 AUTOMÁTICAMENTE
EC2_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo "window.RUNTIME_CONFIG = {
  BACKEND_URL: \"http://$EC2_PUBLIC_IP:8000\"
};" > /usr/share/nginx/html/config.js

echo "CONFIG CREADO:"
cat /usr/share/nginx/html/config.js

# INICIAR NGINX
nginx -g "daemon off;"
