#!/bin/bash

# Get IP address of the server from the first argument from vagrantfile
SERVER_IP="$1"

# Alpine uses eth1 for private network
IFACE="eth1"

# Install curl if not present (Alpine)
if ! command -v curl &> /dev/null; then
    apk add --no-cache curl
fi

# install K3s in server mode
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address $SERVER_IP --flannel-iface=$IFACE" sh -

# Wait for K3s to be fully ready
echo "Waiting for K3s to start..."
sleep 15

# Wait for kubeconfig to exist
echo "Waiting for kubeconfig..."
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
    echo "  kubeconfig not ready yet..."
    sleep 3
done
echo "Kubeconfig is ready!"

# Wait for node-token to exist
echo "Waiting for node-token..."
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    echo "  node-token not ready yet..."
    sleep 3
done
echo "Node-token is ready!"

# Copy kubeconfig config for the vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Share the token with worker via SSH (since /vagrant doesn't work on Alpine)
# Save token to a file that can be fetched via SSH
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo "$TOKEN" > /tmp/node-token
chmod 644 /tmp/node-token
echo "K3s Server setup complete!"
echo "Token saved to /tmp/node-token"