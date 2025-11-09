# Base image
FROM node:18

# Create working folder
WORKDIR /app

# Copy dependency files first
COPY package*.json ./

# Install dependencies
RUN npm install

# copy the rest of the frontend code
COPY . .

# Compile the application
RUN npm run build

# Serve the application
RUN npm install -g serve
CMD ["serve", "-s", "build"]

# Expose port 3000
EXPOSE 3000
