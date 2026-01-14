#!/bin/bash

# Get IP address of the server from the first argument from vagrantfile
SERVER_IP="$1"

# Install curl (needed for Alpine minimal)
if ! command -v curl &> /dev/null; then
    apk add --no-cache curl bash
fi

# Install K3s in server mode (simple and working approach)
# --node-ip: Tell K3s to use this IP for the node
# --write-kubeconfig-mode 0644: Make kubeconfig readable
echo "Installing K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip $SERVER_IP --write-kubeconfig-mode 0644" sh -s -

# Wait for K3s service to be active (Alpine uses OpenRC, not systemd)
echo "Waiting for K3s service..."
sleep 15
while ! rc-service k3s status 2>/dev/null | grep -q "started"; do
    echo "  K3s service not active yet..."
    sleep 2
done
echo "K3s service is active!"

# Wait for kubeconfig to exist
echo "Waiting for kubeconfig..."
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
    sleep 2
done

# Wait for node to be ready
echo "Waiting for node to be Ready..."
until sudo kubectl get nodes 2>/dev/null | grep -q " Ready"; do
    echo "  Node not ready yet..."
    sleep 3
done
echo "K3s node is Ready!"

# Setup kubeconfig for vagrant user
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube
echo 'alias k="kubectl"' >> /home/vagrant/.profile

# Deploy applications
chmod +x /vagrant/scripts/apps-setup.sh
bash /vagrant/scripts/apps-setup.sh $SERVER_IP