#!/bin/sh

# Si ALB_DNS no está definida, usa /api (rutas relativas)
if [ -z "$ALB_DNS" ]; then
  BACKEND_URL="/api"
else
  BACKEND_URL="http://$ALB_DNS"
fi

echo "window.RUNTIME_CONFIG = {
  BACKEND_URL: \"$BACKEND_URL\"
};" > /usr/share/nginx/html/config.js

echo "CONFIG CREADO:"
cat /usr/share/nginx/html/config.js

nginx -g "daemon off;"