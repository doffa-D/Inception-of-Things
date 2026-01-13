#!/bin/bash

server_ip="$1"

echo "Deploying app-one..."
sudo kubectl apply -f /vagrant/confs/app-one.yaml > /dev/null
sudo kubectl wait deployment app-one --for condition=Available=True --timeout=120s > /dev/null
echo "app-one deployed successfully"

echo "Deploying app-two..."
sudo kubectl apply -f /vagrant/confs/app-two.yaml > /dev/null
sudo kubectl wait deployment app-two --for condition=Available=True --timeout=120s > /dev/null
echo "app-two deployed successfully"

echo "Deploying app-three..."
sudo kubectl apply -f /vagrant/confs/app-three.yaml > /dev/null
sudo kubectl wait deployment app-three --for condition=Available=True --timeout=120s > /dev/null
echo "app-three deployed successfully"

echo "Deploying ingress..."
sudo kubectl apply -f /vagrant/confs/ingress.yaml > /dev/null

# Wait for everything to settle (like the reference repo does - 125 seconds)
echo "Waiting for ingress to be ready..."
sleep 125

echo "✓ All apps deployed successfully!"
echo ""
sudo kubectl get all
echo ""
echo "Access at: http://$server_ip"
echo "  - app1: curl -H 'Host: app1.com' http://$server_ip"
echo "  - app2: curl -H 'Host: app2.com' http://$server_ip"
echo "  - app3: curl http://$server_ip (default)"