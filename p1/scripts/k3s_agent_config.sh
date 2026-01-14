#!/bin/bash

# Get IP address of the server from the first argument from vagrantfile
SERVER_IP="$1"
SERVER_NAME="$2"

# Alpine uses eth1 for private network
IFACE="eth1"

# Install curl and sshpass if not present (Alpine)
apk add --no-cache curl sshpass

# wait for the server to be ready
echo "Waiting for server to be ready..."
sleep 45

# Get token from server via SSH
echo "Fetching token from server..."
TOKEN=$(sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@$SERVER_IP "cat /tmp/node-token")

if [ -z "$TOKEN" ]; then
    echo "ERROR: Could not get token from server!"
    exit 1
fi

echo "Token received successfully!"

# install K3s in agent mode
curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" INSTALL_K3S_EXEC="--flannel-iface=$IFACE" sh -

echo "K3s Agent setup complete!"