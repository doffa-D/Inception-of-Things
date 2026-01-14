# 🚀 Inception-of-Things (IoT)

A System Administration project focused on Kubernetes, K3s, K3d, Vagrant, and Argo CD.

---

## 📋 Project Overview

This project introduces Kubernetes concepts through three progressive parts:

| Part | Description | Technologies |
|------|-------------|--------------|
| **Part 1** | Two-node K3s cluster setup | Vagrant, K3s, VirtualBox |
| **Part 2** | Three web applications with Ingress routing | K3s, Ingress, Deployments |
| **Part 3** | K3d cluster with Argo CD (GitOps) | K3d, Docker, Argo CD |

---

## 🏗️ Project Structure

```
Inception-Of-Things/
├── p1/                          # Part 1: K3s + Vagrant (2 nodes)
│   ├── Vagrantfile
│   └── scripts/
│       ├── k3s_server_config.sh
│       └── k3s_agent_config.sh
│
├── p2/                          # Part 2: K3s + 3 Applications
│   ├── Vagrantfile
│   ├── confs/
│   │   ├── app-one.yaml
│   │   ├── app-two.yaml
│   │   ├── app-three.yaml
│   │   └── ingress.yaml
│   └── scripts/
│       └── apps-setup.sh
│
├── p3/                          # Part 3: K3d + Argo CD
│   ├── confs/
│   │   └── application.yaml
│   └── scripts/
│       ├── install-tools.sh
│       └── start.sh
│
└── README.md
```

---

## 🔷 Part 1: K3s and Vagrant

### Description
Set up a two-node Kubernetes cluster using Vagrant and K3s.

### Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    K3s CLUSTER                          │
│                                                         │
│  ┌─────────────────────┐    ┌─────────────────────┐     │
│  │  HdagdaguS (Server) │    │  HdagdaguSW (Worker)│     │
│  │  192.168.56.110     │◄──►│  192.168.56.111     │     │
│  │  K3s Server         │    │  K3s Agent          │     │
│  └─────────────────────┘    └─────────────────────┘     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Usage
```bash
cd p1
vagrant up
vagrant ssh HdagdaguS
kubectl get nodes -o wide
```

---

## 🔷 Part 2: K3s and Three Applications

### Description
Deploy three web applications with Ingress-based routing on a single K3s node.

### Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    K3s CLUSTER                          │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │   app-one   │  │   app-two   │  │  app-three  │      │
│  │  (1 replica)│  │ (3 replicas)│  │  (1 replica)│      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
│         ▲                ▲                ▲             │
│         │                │                │             │
│  ┌──────┴────────────────┴────────────────┴──────┐      │
│  │                   INGRESS                     │      │
│  │  app1.com → app-one                           │      │
│  │  app2.com → app-two                           │      │
│  │  default  → app-three                         │      │
│  └───────────────────────────────────────────────┘      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Usage
```bash
cd p2
vagrant up
vagrant ssh HdagdaguS

# Test applications
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110
```

---

## 🔷 Part 3: K3d and Argo CD

### Description
Set up a K3d cluster with Argo CD for GitOps-based continuous deployment.

### Architecture
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   GitHub                        K3d CLUSTER             │
│   ┌──────────────┐             ┌─────────────────────┐  │
│   │ hdagdagu-ioft│             │                     │  │
│   │    repo      │◄── watches ─│     ARGO CD         │  │
│   │    /dev      │             │   (argocd ns)       │  │
│   └──────────────┘             └──────────┬──────────┘  │
│                                           │             │
│                                           ▼ deploys     │
│                                ┌─────────────────────┐  │
│   curl localhost:8888 ────────►│    APPLICATION      │  │
│                                │     (dev ns)        │  │
│                                └─────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Usage
```bash
cd p3/scripts
./start.sh

# Test application
curl localhost:8888

# Access Argo CD UI
# Open: https://localhost:8080
# Username: admin
# Password: (shown in terminal output)
```

### GitOps Demo
1. Check current version: `curl localhost:8888`
2. Change version in GitHub (`hdagdagu-ioft/dev/deployment.yaml`)
3. Wait for Argo CD to sync (or manually sync in UI)
4. Verify update: `curl localhost:8888`

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| **Vagrant** | VM automation |
| **VirtualBox** | Virtualization |
| **K3s** | Lightweight Kubernetes |
| **K3d** | K3s in Docker |
| **Docker** | Container runtime |
| **Argo CD** | GitOps CD tool |
| **kubectl** | Kubernetes CLI |

---

## 📚 Key Concepts

### Kubernetes Hierarchy
```
CLUSTER → NODE → NAMESPACE → DEPLOYMENT → POD → CONTAINER
```

### K3s vs K3d
| Feature | K3s | K3d |
|---------|-----|-----|
| Runs on | Real VMs | Docker containers |
| Setup | Heavier | Lighter |
| Use case | Production-like | Development |

### GitOps
> Git is the single source of truth. Changes in Git automatically sync to the cluster.

---

## 📝 Quick Commands

```bash
# Cluster info
kubectl get nodes -o wide
kubectl get ns
kubectl get pods -A

# Deployments
kubectl get deployments
kubectl get svc
kubectl get ingress

# Argo CD
kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

---

## 👤 Author

**Hdagdagu** (doffa)

---

## 📄 License

This project is part of the 42 School curriculum.
