#!/bin/sh

# Usa la variable de entorno ALB_DNS (pasada desde docker-compose)
BACKEND_URL="http://${ALB_DNS}"

echo "window.RUNTIME_CONFIG = {
  BACKEND_URL: \"$BACKEND_URL\"
};" > /usr/share/nginx/html/config.js

echo "CONFIG CREADO:"
cat /usr/share/nginx/html/config.js

nginx -g "daemon off;"