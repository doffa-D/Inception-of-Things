# 📋 Inception-of-Things - Evaluation Commands

## Commands You Need During Defense

---

# 🔷 Part 1: K3s and Vagrant (2 Nodes)

## Start the VMs:
```bash
cd p1
vagrant up
```

## SSH into Server:
```bash
vagrant ssh HdagdaguS
```

## SSH into Worker:
```bash
vagrant ssh HdagdaguSW
```

## Check network interface (IP address):
```bash
# Modern Linux (use this):
ip a show enp0s8

# Or older systems:
ifconfig eth1
```

## Verify hostname:
```bash
hostname
```

## Check K3s is running:
```bash
# On Server:
sudo systemctl status k3s

# On Worker:
sudo systemctl status k3s-agent
```

## Verify both nodes are in the cluster (RUN ON SERVER):
```bash
kubectl get nodes -o wide
```

**Expected output:**
```
NAME          STATUS   ROLES                  AGE   VERSION        INTERNAL-IP
hdagdagus     Ready    control-plane,master   5m    v1.xx.x+k3s1   192.168.56.110
hdagdagusw    Ready    <none>                 3m    v1.xx.x+k3s1   192.168.56.111
```

## Stop VMs when done:
```bash
vagrant halt
```

---

# 🔷 Part 2: K3s and Three Applications

## Start the VM:
```bash
cd p2
vagrant up
```

## SSH into the VM:
```bash
vagrant ssh HdagdaguS
```

## Check network interface:
```bash
ip a show enp0s8
```

## Verify hostname:
```bash
hostname
```

## Check K3s is running:
```bash
sudo systemctl status k3s
```

## Show nodes:
```bash
kubectl get nodes -o wide
```

## Show all resources in kube-system (shows 3 apps):
```bash
kubectl get all -n kube-system
```

## Show deployments (verify app-two has 3 replicas):
```bash
kubectl get deployments
```

**Expected output:**
```
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
app-one     1/1     1            1           5m
app-two     3/3     3            3           5m    ← 3 replicas!
app-three   1/1     1            1           5m
```

## Show pods:
```bash
kubectl get pods
```

## Show services:
```bash
kubectl get svc
```

## Show Ingress (IMPORTANT - evaluator will ask!):
```bash
kubectl get ingress
```

## Describe Ingress (show routing rules):
```bash
kubectl describe ingress iot-ingress
```

## Test the 3 applications:
```bash
# Test app1 (Host: app1.com)
curl -H "Host: app1.com" http://192.168.56.110

# Test app2 (Host: app2.com)
curl -H "Host: app2.com" http://192.168.56.110

# Test app3 (default - no host)
curl http://192.168.56.110
```

## Stop VM when done:
```bash
vagrant halt
```

---

# 🔷 Part 3: K3d and Argo CD

## Run the setup script:
```bash
cd p3/scripts
./start.sh
```

## Check namespaces (must show argocd and dev):
```bash
kubectl get ns
```

**Expected output:**
```
NAME              STATUS   AGE
argocd            Active   5m
default           Active   5m
dev               Active   5m
kube-node-lease   Active   5m
kube-public       Active   5m
kube-system       Active   5m
```

## Check pods in dev namespace:
```bash
kubectl get pods -n dev
```

**Expected output:**
```
NAME                   READY   STATUS    RESTARTS   AGE
app-xxxxxxxxx-xxxxx    1/1     Running   0          5m
```

## Check pods in argocd namespace:
```bash
kubectl get pods -n argocd
```

## Check all services:
```bash
kubectl get svc -A
```

## Get Argo CD admin password:
```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode && echo
```

## Access Argo CD UI:
```bash
# Port forward (if not already running)
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```
Then open: **https://localhost:8080**
- Username: `admin`
- Password: (from command above)

## Test the application:
```bash
curl localhost:8888
```

**Expected output:**
```json
{"status":"ok", "message": "v1"}
```
or
```json
{"status":"ok", "message": "v2"}
```

## Check current version in deployment:
```bash
kubectl get deployment -n dev -o yaml | grep image
```

---

# 🔷 Part 3: GitOps Demo (Version Change)

## Step 1: Check current version
```bash
curl localhost:8888
# Note: v1 or v2
```

## Step 2: Change version on GitHub
Go to: `https://github.com/doffa-D/ioft/blob/main/dev/deployment.yaml`

Edit the file and change:
```yaml
# From:
image: wil42/playground:v1

# To:
image: wil42/playground:v2
```
(or vice versa)

Commit the change.

## Step 3: Wait for Argo CD to sync
- Option A: Wait ~3 minutes for auto-sync
- Option B: Click "Sync" button in Argo CD UI

## Step 4: Verify the update
```bash
curl localhost:8888
# Should show new version
```

## Alternative: Change version via command line
```bash
# Clone your repo
git clone https://github.com/doffa-D/ioft.git
cd ioft

# Change version
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' dev/deployment.yaml

# Push changes
git add .
git commit -m "Update to v2"
git push
```

---

# 🔷 Cleanup Commands

## Delete K3d cluster:
```bash
k3d cluster delete ioft-cluster
```

## Stop all Vagrant VMs:
```bash
# In p1 folder:
cd p1 && vagrant halt

# In p2 folder:
cd p2 && vagrant halt
```

## Destroy Vagrant VMs (delete completely):
```bash
vagrant destroy -f
```

---

# 🔷 Troubleshooting Commands

## Check K3d clusters:
```bash
k3d cluster list
```

## Check Docker containers:
```bash
docker ps
```

## Check pod logs:
```bash
kubectl logs -n dev <pod-name>
```

## Describe pod (for debugging):
```bash
kubectl describe pod -n dev <pod-name>
```

## Force sync in Argo CD:
```bash
kubectl -n argocd exec -it deploy/argocd-server -- argocd app sync ioft-application
```

## Restart a deployment:
```bash
kubectl rollout restart deployment -n dev app
```

---

# 📝 Quick Reference Card

| Part | Key Commands |
|------|--------------|
| **Part 1** | `vagrant up`, `vagrant ssh`, `kubectl get nodes -o wide` |
| **Part 2** | `kubectl get deployments`, `kubectl get ingress`, `curl -H "Host: app1.com"` |
| **Part 3** | `kubectl get ns`, `kubectl get pods -n dev`, `curl localhost:8888` |
| **GitOps** | Change GitHub → Wait sync → `curl localhost:8888` |

---

## Good Luck! 🎉
