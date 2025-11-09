# Imagen base
FROM node:18

# Crear carpeta de trabajo
WORKDIR /app

# Copiar archivos de dependencias primero
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código del frontend
COPY . .

# Compilar la aplicación
RUN npm run build

# Servir la aplicación
RUN npm install -g serve
CMD ["serve", "-s", "build"]

# Exponer el puerto 3000
EXPOSE 3000
