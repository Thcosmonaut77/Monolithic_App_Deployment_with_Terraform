#!/bin/bash
set -e

# Update system
sudo apt update -y
sudo apt install -y openjdk-21-jdk ca-certificates git maven wget gnupg lsb-release

# Add Jenkins key and repo
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update -y
sudo apt install -y terraform

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Print Jenkins password
echo "Waiting for Jenkins to initialize..."
sleep 10

echo "Jenkins is installed!"
echo "Default admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
