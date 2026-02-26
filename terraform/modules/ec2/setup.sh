#!/bin/bash
set -e

# Update system
sudo apt-get update -y

# Install dependencies
sudo apt-get install -y git curl

# Install Docker using official script
curl -fsSL https://get.docker.com | sudo sh

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Clone project
git clone https://github.com/DevOpsAutomatorAdi/Two-tier-Deployment-using-Terraform-JenkinsCI-CD.git
cd loginflask

# Run containers using new Docker compose syntax
sudo docker compose up -d
