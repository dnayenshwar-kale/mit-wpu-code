#!/bin/bash

# Azure VM Deployment Script
# This script sets up the Spring Boot application on an Azure VM

set -e

echo "Starting Azure VM deployment..."

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java 17
echo "Installing Java 17..."
sudo apt install -y openjdk-17-jre-headless

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /opt/demo-app
sudo chown $USER:$USER /opt/demo-app

# Pull and run the Docker container
echo "Pulling and running Docker container..."
cd /opt/demo-app

# Login to GitHub Container Registry (if needed)
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Pull the latest image
docker pull ghcr.io/dnayenshwar-kale/mit-wpu-code:latest

# Stop and remove existing container if running
docker stop demo-app || true
docker rm demo-app || true

# Run the container
docker run -d \
  --name demo-app \
  --restart unless-stopped \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod,azure \
  -e AZURE_DB_URL="$AZURE_DB_URL" \
  -e AZURE_DB_USERNAME="$AZURE_DB_USERNAME" \
  -e AZURE_DB_PASSWORD="$AZURE_DB_PASSWORD" \
  -e APPINSIGHTS_INSTRUMENTATIONKEY="$APPINSIGHTS_INSTRUMENTATIONKEY" \
  ghcr.io/dnayenshwar-kale/mit-wpu-code:latest

# Install nginx (optional reverse proxy)
echo "Installing nginx..."
sudo apt install -y nginx

# Configure nginx
sudo tee /etc/nginx/sites-available/demo-app > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/demo-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

echo "Deployment completed successfully!"
echo "Application is running at http://$(curl -s http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text):80"