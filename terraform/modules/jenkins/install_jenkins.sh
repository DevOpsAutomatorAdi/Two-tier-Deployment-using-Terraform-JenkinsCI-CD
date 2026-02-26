#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y

echo "Installing Java..."
sudo apt install -y fontconfig openjdk-21-jre

echo "Installing required tools..."
sudo apt install -y curl gnupg git

echo "Adding Jenkins repository key..."
sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "Adding Jenkins repository..."
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating repositories..."
sudo apt update -y

echo "Installing Jenkins..."
sudo apt install -y jenkins

echo "Creating Jenkins admin user..."

JENKINS_USER="admin"
JENKINS_PASS="Admin@123"

sudo mkdir -p /var/lib/jenkins/init.groovy.d

sudo tee /var/lib/jenkins/init.groovy.d/basic-security.groovy > /dev/null <<EOF
#!groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("${JENKINS_USER}", "${JENKINS_PASS}")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

echo "Disabling setup wizard..."
echo 'JAVA_ARGS="-Djenkins.install.runSetupWizard=false"' | sudo tee -a /etc/default/jenkins

echo "Starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "Waiting Jenkins to initialize..."
sleep 40

echo "Saving credentials..."

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<CREDS > /home/ubuntu/jenkins-login.txt
Jenkins URL: http://$PUBLIC_IP:8080

Username: ${JENKINS_USER}
Password: ${JENKINS_PASS}
CREDS

chmod 644 /home/ubuntu/jenkins-login.txt

echo "Jenkins setup completed!"