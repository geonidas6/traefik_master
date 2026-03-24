#!/bin/bash

# Configuration
REPO_URL="https://github.com/geonidas6/traefik_master.git"
INSTALL_DIR="/opt/traefik_master"

# Ensure we are running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo "Git not found, installing..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y git
    elif command -v yum &> /dev/null; then
        yum install -y git
    else
        echo "Could not install git. Please install it manually."
        exit 1
    fi
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing..."
    curl -fsSL https://get.docker.com | sh
fi

# Clone the repository
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
else
    echo "Directory $INSTALL_DIR already exists, updating..."
    cd "$INSTALL_DIR" && git pull
fi

cd "$INSTALL_DIR"

# Setup .env
if [ ! -f .env ]; then
    echo "Configuring .env..."
    read -p "Enter ACME_EMAIL (for SSL certificates): " acme_email
    echo "ACME_EMAIL=$acme_email" > .env
fi

# Ensure network exists
docker network create proxy_net 2>/dev/null || true

# Start the stack
echo "Starting Traefik Master..."
docker compose up -d

echo "Installation complete!"
echo "You can check the logs with: cd $INSTALL_DIR && docker compose logs -f"
