#!/bin/bash

# Step 1: Install tools first
echo "==> Installing required tools..."
./install-tools.sh

echo ""
echo "==> Starting Part 3 setup..."
echo ""

echo "Deleting existing cluster (if any)..."
k3d cluster delete ioft-cluster 2>/dev/null

echo "Creating new cluster..."
k3d cluster create ioft-cluster -p "8888:30080@server:0" >/dev/null

echo "Create agrocd namespace..."
kubectl create namespace argocd


echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


echo "Waiting for ArgoCD server to be ready..."
kubectl wait -n argocd --for=condition=Ready pods --all --timeout=300s


echo "Agro CD admin password:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo ""


echo "==> Creating dev namespace..."
kubectl create namespace dev



echo "==> Applying Argo CD application..."
kubectl apply -f ../confs/application.yaml


echo "==> Starting Argo CD UI..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
#↑ Make Argo CD web interface accessible at https://localhost:8080

echo "==> Waiting for app to be deployed by Argo CD..."
POD_STATE=""
while [ "$POD_STATE" != "Running" ]; do
    echo "Waiting for app pod to be created..."
    POD_STATE=$(kubectl get po -n dev --output="jsonpath={.items..phase}" 2>/dev/null)
    sleep 5
done
echo "App pod is running!"

echo ""
echo "=========================================="
echo "✅ Part 3 Setup Complete!"
echo "=========================================="
echo "Argo CD UI: https://localhost:8080"
echo "App: curl localhost:8888"
echo "=========================================="