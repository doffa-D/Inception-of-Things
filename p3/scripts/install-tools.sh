#!/bin/bash

echo "Check Docker..."

if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get update

    # ca-certificates : SSL certificates to verify HTTPS downloads
    # gnupg : GPG encryption - to verify Docker's signature 
    # lsb-release : is a tool that tells you which Linux version you're running Why Do We Need It? Docker has different packages for each Ubuntu version
    
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Create the keyrings directory if it doesn't exist for storing GPG keys
    sudo mkdir -m 0755 -p /etc/apt/keyrings

    # Downloads Docker's security key (GPG) and saves it to the keyrings directory
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
docker --version

echo "Check k3d..."
if ! command -v k3d &> /dev/null; then
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi
k3d version

echo "Check kubectl..."
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
fi
kubectl version --client

echo "All tools installed successfully."