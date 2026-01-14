# 📋 Inception-of-Things - Evaluation Q&A

## Quick Reference for Defense

---

# Part 1: K3s and Vagrant (2 Nodes)

### Q: What is the difference between Server and Worker?
**A:** Server (Master) = Brain that controls the cluster. Worker (Agent) = Muscle that runs the pods.

### Q: How does the Worker join the Server?
**A:** Worker uses a TOKEN from the Server + Server's IP address to join the cluster.

### Q: What is the Server IP and Worker IP?
**A:** Server: 192.168.56.110, Worker: 192.168.56.111

### Q: What port does K3s API use?
**A:** Port 6443

### Q: How to verify both nodes are connected?
**A:** `kubectl get nodes` - should show 2 nodes with "Ready" status.

---

# Part 2: K3s and Three Applications

### Q: How many replicas does app-two have?
**A:** 3 replicas (required by subject).

### Q: How does Ingress routing work?
**A:**
- `Host: app1.com` → app-one-service → app-one pod
- `Host: app2.com` → app-two-service → app-two pods (load balanced)
- `No host (default)` → app-three-service → app-three pod

### Q: What is a Deployment?
**A:** Manages pods - creates them, updates them, maintains the desired number of replicas.

### Q: What is a Service?
**A:** Stable network endpoint that routes traffic to pods. Pods can die and restart with new IPs, but Service IP stays the same.

### Q: What is an Ingress?
**A:** Traffic router that directs external requests to the correct Service based on rules (like Host header).

### Q: How to test the apps?
**A:**
```bash
curl -H "Host: app1.com" http://192.168.56.110  # → App 1
curl -H "Host: app2.com" http://192.168.56.110  # → App 2
curl http://192.168.56.110                       # → App 3 (default)
```

---

# Part 3: K3d and Argo CD

### Q: What is the difference between K3s and K3d?
**A:**
- K3s = Kubernetes that runs on real VMs
- K3d = K3s running inside Docker containers (faster, lighter)

### Q: What is Argo CD?
**A:** A tool that watches your GitHub repo and automatically deploys changes to your Kubernetes cluster.

### Q: What is GitOps?
**A:** Git is the "single source of truth". All changes go through Git, and tools like Argo CD sync the cluster to match Git.

### Q: What does `selfHeal: true` mean?
**A:** If someone manually changes the cluster, Argo CD will automatically fix it back to match Git.

### Q: What does `prune: true` mean?
**A:** If you delete something from Git, Argo CD will delete it from the cluster too.

### Q: What is the command to create the K3d cluster?
**A:** `k3d cluster create ioft-cluster -p "8888:30080@server:0"`

### Q: What does `-p "8888:30080@server:0"` mean?
**A:** Maps localhost port 8888 to NodePort 30080 on the K3d server node.

### Q: How to test the app in Part 3?
**A:** `curl localhost:8888` → Should return `{"status":"ok", "message": "v1"}` or `v2`

### Q: How to demonstrate GitOps (version change)?
**A:**
1. `curl localhost:8888` → shows current version (v1 or v2)
2. Change `image: wil42/playground:v1` to `v2` in GitHub
3. Wait for Argo CD to sync (or click Sync in UI)
4. `curl localhost:8888` → shows new version

### Q: What are the two namespaces in Part 3?
**A:**
- `argocd` - Contains Argo CD pods
- `dev` - Contains your application pod

---

# General Kubernetes Questions

### Q: What is a Cluster?
**A:** Group of machines (nodes) working together to run containers.

### Q: What is a Node?
**A:** A machine in the cluster that runs pods.

### Q: What is a Pod?
**A:** Smallest unit in Kubernetes. Wrapper around one or more containers.

### Q: What is a Container?
**A:** Your actual application running (like a Docker container).

### Q: What is a Namespace?
**A:** Logical folder to organize resources (like `default`, `argocd`, `dev`).

### Q: What is Kubernetes?
**A:** A system that manages containers - runs them, monitors them, restarts them if they crash, and scales them up or down.

### Q: Hierarchy from smallest to largest?
**A:** Container → Pod → Deployment → Namespace → Node → Cluster

---

# Useful Commands

```bash
# Cluster
kubectl get nodes                    # List nodes
k3d cluster list                     # List K3d clusters

# Namespaces
kubectl get ns                       # List namespaces

# Pods
kubectl get pods                     # List pods (default namespace)
kubectl get pods -n dev              # List pods in dev namespace
kubectl get pods -A                  # List all pods in all namespaces

# Deployments
kubectl get deployments              # List deployments

# Services
kubectl get svc                      # List services

# Ingress
kubectl get ingress                  # List ingress
kubectl describe ingress <name>      # Show ingress details

# Argo CD
kubectl get pods -n argocd           # Check Argo CD pods
kubectl port-forward svc/argocd-server -n argocd 8080:443  # Access UI
```

---

# Quick Test Commands

```bash
# Part 1
vagrant up                           # Start VMs
vagrant ssh HdagdaguS                # SSH to server
kubectl get nodes                    # Verify 2 nodes

# Part 2
vagrant up                           # Start VM
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110

# Part 3
./start.sh                           # Run setup script
curl localhost:8888                  # Test app
# Open https://localhost:8080 for Argo CD UI
```

---

# Visual Summary

```
CLUSTER (group of machines)
│
├── NODE 1 (Server/Master)
│   └── Controls everything
│
└── NODE 2 (Worker/Agent)
    ├── Pod A
    │   └── Container (your app)
    ├── Pod B
    │   └── Container
    └── Pod C
        └── Container
```

---

## Good Luck with Your Evaluation! 🎉
