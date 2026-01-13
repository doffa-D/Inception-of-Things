#!/bin/bash

# Get IP address of the server from the first argument from vagrantfile
SERVER_IP="$1"
SERVER_NAME="$2"

# wait for the server to be ready
echo "Waiting for server to be ready..."
sleep 30

# Get token from shared folder
TOKEN=$(cat /vagrant/node-token)

# install K3s in agent mode - disable load balancer
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" INSTALL_K3S_EXEC="--flannel-iface=eth1" sh -