#!/bin/bash

# Get IP address of the server from the first argument from vagrantfile
SERVER_IP="$1"

# install K3s in server mode
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--bind-address $SERVER_IP --flannel-iface=eth1" sh -


# wait for k3s to be fully up and running
sleep 10

# Copy kubeconfig config for the vagrant user
mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Share the token with worker via /vagrant (shared folder)
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token