# Inception-of-Things Evaluation Guide

This file is a simple defense checklist based on the mandatory evaluation requirements.

The goal is not only to make everything work, but also to be able to explain what is happening.

---

# 1. Global Explanation

Before starting the technical checks, be ready to explain these four ideas simply.

## K3s

Kubernetes is a system that manages containerized applications.

It can start applications, keep them running, restart them if they fail, and manage multiple copies of the same application.

K3s is a lightweight version of Kubernetes.

Kubernetes manages containers and applications.

K3s gives us the main Kubernetes features while using fewer resources, which makes it good for small virtual machines and learning environments.

Simple idea:

```text
K3s
 ↓
manages Pods
 ↓
keeps applications running
```

Instead of one copy doing all the work:

300 users
    ↓
  Pod 1

you can spread the work:

300 users
    ↓
 Service
   ↙ ↓ ↘
Pod1 Pod2 Pod3

Maybe approximately:

Pod 1 handles 100 users
Pod 2 handles 100 users
Pod 3 handles 100 users


Before:

my-app-abc ✅
my-app-def ✅
my-app-ghi ✅

One dies:

my-app-abc ✅
my-app-def ❌
my-app-ghi ✅

Kubernetes creates another:

my-app-abc ✅
my-app-ghi ✅
my-app-xyz ✅




## Vagrant

Vagrant automatically creates and configures virtual machines.

Instead of manually creating VirtualBox machines, we describe the machines in a `Vagrantfile`.

Then:

```bash
vagrant up
```

creates and starts them.

Simple idea:

```text
Vagrantfile
 ↓
Vagrant
 ↓
VirtualBox VM
```

## K3d

K3d runs K3s inside Docker containers.

It lets us create a Kubernetes cluster without creating additional VirtualBox virtual machines.

Simple idea:

```text
Docker
 ↓
K3d
 ↓
K3s
 ↓
Kubernetes cluster
```

## Continuous Integration and Argo CD

Continuous Integration means code changes are frequently integrated and automatically checked or processed.

In this project, Argo CD is mainly used for GitOps and continuous deployment.

Argo CD watches the Kubernetes configuration stored in GitHub.

If the GitHub configuration changes:

```text
GitHub
 ↓
Argo CD notices the change
 ↓
Kubernetes is updated
 ↓
Application changes
```

For example:

```text
v1 → GitHub change → Argo CD → v2
```

---

# 2. Part 1 Configuration

Part 1 uses two Vagrant virtual machines and K3s.

## Check the files

From the project root:

```bash
find p1 -maxdepth 3 -type f
```

Expected structure:

```text
p1/
├── Vagrantfile
└── scripts/
    ├── server.sh
    └── worker.sh
```

## Inspect the Vagrantfile

```bash
cat p1/Vagrantfile
```

Be ready to explain:

* Why there are two machines
* Their names
* Their hostnames
* Their IP addresses
* Their memory and CPU configuration
* Which provisioning script each machine uses

There must be:

```text
Server machine
ServerWorker machine
```

The names must contain a 42 login.

Example:

```text
loginS
loginSW
```

Required addresses:

```text
Server:       192.168.56.110
ServerWorker: 192.168.56.111
```

## Start Part 1

From the root:

```bash
make task1
```

Check status:

```bash
make status1
```

---

# 3. Part 1 Usage

## SSH into Server

From:

```bash
cd p1
```

run:

```bash
vagrant ssh <server-name>
```

For example:

```bash
vagrant ssh vmS
```

## Check the primary network interface

Inside the VM:

```bash
ip a show $(ip route | grep default | awk '{print $5}')
```

Also inspect all interfaces if needed:

```bash
ip a
```

Confirm the required address is present.

Server:

```text
192.168.56.110
```

Worker:

```text
192.168.56.111
```

## Check hostname

Inside each VM:

```bash
hostname
```

The Server should end with:

```text
S
```

The Worker should end with:

```text
SW
```

## Check K3s

On the Server:

```bash
sudo systemctl status k3s
```

On the Worker:

```bash
sudo systemctl status k3s-agent
```

## Check both nodes are in the same cluster

On the Server:

```bash
kubectl get nodes -o wide
```

You should see both machines.

Conceptually:

```text
NAME     STATUS   ROLES
vmS      Ready    control-plane
vmSW     Ready
```

Be ready to explain:

* `NAME` = Kubernetes node name
* `STATUS` = whether Kubernetes considers it healthy
* `ROLES` = controller or worker role
* `INTERNAL-IP` = node network address

## Stop Part 1

```bash
make stop1
```

Delete it completely if necessary:

```bash
make clean1
```

---

# 4. Part 2 Configuration

Part 2 uses one Vagrant VM with K3s server mode.

Before starting Part 2, Part 1 can be stopped to save memory and disk space.

```bash
make stop1
```

## Check files

```bash
find p2 -maxdepth 3 -type f
```

Expected structure:

```text
p2/
├── Vagrantfile
└── scripts/
    └── server.sh
```

There may also be Kubernetes configuration files inside:

```text
p2/confs/
```

## Inspect Vagrantfile

```bash
cat p2/Vagrantfile
```

Be ready to explain:

* Why there is only one machine
* Its name
* Its hostname
* Its IP
* How K3s is installed

The name must contain a login followed by:

```text
S
```

The required IP is:

```text
192.168.56.110
```

## Start Part 2

```bash
make task2
```

Check:

```bash
make status2
```

---

# 5. Part 2 Usage

## SSH into the VM

```bash
cd p2
vagrant ssh
```

or, if the machine has an explicit name:

```bash
vagrant ssh vmS
```

## Check network

```bash
ip a show $(ip route | grep default | awk '{print $5}')
```

Also:

```bash
ip a
```

Confirm:

```text
192.168.56.110
```

## Check hostname

```bash
hostname
```

## Check K3s

```bash
sudo systemctl status k3s
```

## Check Kubernetes node

```bash
kubectl get nodes -o wide
```

There should be one controller node.

## Check applications

```bash
kubectl get all
```

You should be able to explain:

* Pod
* Deployment
* ReplicaSet
* Service

The project requires three applications.

One application must have three replicas.

You can check deployments with:

```bash
kubectl get deployments
```

## Check Ingress

The evaluator deliberately does not give this command.

You should know it:

```bash
kubectl get ingress
```

More detail:

```bash
kubectl describe ingress
```

The Ingress decides which application receives a request based on its `Host` header.

Conceptually:

```text
Request
   |
   v
Ingress
   |
   +--> app1.com → app1
   |
   +--> app2.com → app2
   |
   +--> other → app3
```

## Test the three applications

Example:

```bash
curl -H "Host: app1.com" http://192.168.56.110
```

```bash
curl -H "Host: app2.com" http://192.168.56.110
```

And test the default application with another Host value:

```bash
curl -H "Host: somethingelse.com" http://192.168.56.110
```

The output should change depending on the Host header.

## Stop Part 2

```bash
make stop2
```

Delete completely if needed:

```bash
make clean2
```

---

# 6. Part 3 Configuration

Part 3 uses:

```text
Docker
K3d
K3s
kubectl
Argo CD
GitHub
```

Unlike Parts 1 and 2, Part 3 does not create extra Vagrant machines.

chmod +x ~/p3/scripts/setup.sh
sudo usermod -aG docker "$USER"
bash ~/p3/scripts/setup.sh

## Connect from the student computer

For normal VM access:

```bash
ssh -p 2222 vm@127.0.0.1
```

For Part 3 with the Argo CD browser tunnel:

```bash
ssh -p 2222 -L 8080:localhost:8080 vm@127.0.0.1
```

## Check Part 3 files

```bash
find p3 -maxdepth 3 -type f
```

Expected structure should include:

```text
p3/
├── scripts/
└── confs/
    ├── deployment.yaml
    └── service.yaml
```

The subject also requires a script able to install the necessary Part 3 tools during the defense.

That script should be placed under:

```text
p3/scripts/
```

## Start Part 3

```bash
make task3
```

Then:

```bash
make status3
```

## Check K3d

```bash
k3d cluster list
```

You should see the `iot` cluster.

Example:

```text
NAME   SERVERS   AGENTS
iot    1/1       0/0
```

## Check Kubernetes node

```bash
kubectl get nodes
```

You should see:

```text
k3d-iot-server-0
```

with:

```text
Ready
```

---

# 7. Part 3 Namespaces

Check:

```bash
kubectl get ns
```

At minimum, these must exist:

```text
argocd
dev
```

## Namespace vs Pod

Be ready to explain the difference.

A namespace is like a room or folder used to organize Kubernetes resources.

A Pod is something that actually runs one or more containers.

Example:

```text
Kubernetes cluster
|
├── argocd namespace
│   ├── Argo CD pod
│   ├── Redis pod
│   └── repo-server pod
│
└── dev namespace
    └── application pod
```

## Check the dev application

```bash
kubectl get pods -n dev
```

There must be at least one Pod.

More detail:

```bash
kubectl get all -n dev
```

---

# 8. Check Argo CD

Check the Argo CD Pods:

```bash
kubectl get pods -n argocd
```

They should be:

```text
Running
```

Start access to the Argo CD UI:

```bash
make argocd-ui
```

Keep that terminal open.

From the student computer browser, open:

```text
https://localhost:8080
```

Username:

```text
admin
```

Get the password:

```bash
make argocd-password
```

---

# 9. Explain Argo CD

The important idea is:

```text
GitHub contains desired configuration
               |
               v
           Argo CD
               |
        compares GitHub
        with Kubernetes
               |
               v
        Kubernetes cluster
```

For example, GitHub says:

```yaml
image: wil42/playground:v1
```

Argo CD makes Kubernetes run:

```text
wil42/playground:v1
```

If GitHub changes to:

```yaml
image: wil42/playground:v2
```

Argo CD detects the difference and updates Kubernetes.

This is the main Part 3 workflow.

---

# 10. Check GitHub Repository

The GitHub repository must be public.

Its name must include a login from a member of the group.

Example:

```text
hongbae-iot
```

Check Git configuration:

```bash
git remote -v
```

Check current branch:

```bash
git branch
```

Check status:

```bash
git status
```

---

# 11. Check Docker Image

Inspect the deployment:

```bash
cat p3/confs/deployment.yaml
```

Look for:

```yaml
image: wil42/playground:v1
```

The subject allows using Wil's Docker image.

Its application listens on:

```text
8888
```

The image must have two versions:

```text
v1
v2
```

If using your own Docker image, the Docker Hub repository name must contain a group member's login.

---

# 12. Part 3 Usage: Test v1

Check the running deployment:

```bash
kubectl get deployments -n dev
```

Check Pods:

```bash
kubectl get pods -n dev
```

Inspect the image:

```bash
kubectl get deployment -n dev -o wide
```

or:

```bash
kubectl get deployment -n dev -o yaml | grep image:
```

You should see:

```text
wil42/playground:v1
```

The application should return something like:

```json
{"status":"ok","message":"v1"}
```

The exact curl method depends on how the service is exposed.

---

# 13. Change v1 to v2

This is one of the most important parts of the evaluation.

Edit:

```text
p3/confs/deployment.yaml
```

Change:

```yaml
image: wil42/playground:v1
```

to:

```yaml
image: wil42/playground:v2
```

You can use:

```bash
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/' p3/confs/deployment.yaml
```

Check:

```bash
grep image p3/confs/deployment.yaml
```

Then commit:

```bash
git add p3/confs/deployment.yaml
git commit -m "update playground to v2"
git push
```

The important point is:

```text
You do NOT manually update Kubernetes.
```

You update GitHub.

Then:

```text
GitHub
 ↓
Argo CD
 ↓
Kubernetes
 ↓
v2
```

---

# 14. Check Argo CD Synchronization

Open the Argo CD UI:

```text
https://localhost:8080
```

Find the application.

Argo CD may show:

```text
OutOfSync
```

briefly after the GitHub change.

If automatic synchronization is enabled, it should automatically become:

```text
Synced
Healthy
```

If automatic synchronization does not happen, synchronize manually from the Argo CD UI.

Then verify from the terminal:

```bash
kubectl get pods -n dev
```

Check the image:

```bash
kubectl get deployment -n dev -o yaml | grep image:
```

It should now contain:

```text
wil42/playground:v2
```

Finally access the app again.

Expected result:

```json
{"status":"ok","message":"v2"}
```

---

# 15. Important Commands to Remember

## Part 1

```bash
make task1
make status1
make stop1
make clean1
```

Inside p1:

```bash
vagrant ssh
kubectl get nodes -o wide
```

## Part 2

```bash
make task2
make status2
make stop2
make clean2
```

Inside Part 2 VM:

```bash
kubectl get nodes -o wide
kubectl get all
kubectl get ingress
```

## Part 3

```bash
make task3
make status3
make stop3
make clean3
```

Argo CD:

```bash
make argocd-ui
make argocd-password
```

Kubernetes:

```bash
kubectl get ns
kubectl get pods -n argocd
kubectl get pods -n dev
kubectl get all -n dev
```

Git:

```bash
git status
git add .
git commit -m "message"
git push
```

---

# 16. Defense Mental Model

The easiest way to remember the three parts is:

## Part 1

```text
Vagrant
 ↓
2 Virtual Machines
 ↓
K3s Server + Worker
 ↓
One Kubernetes cluster
```

## Part 2

```text
Vagrant
 ↓
1 Virtual Machine
 ↓
K3s
 ↓
3 Applications
 ↓
Services
 ↓
Ingress
```

## Part 3

```text
Docker
 ↓
K3d
 ↓
K3s
 ↓
Argo CD
 ↑
GitHub
 ↓
dev application
```

The evaluator is not only checking whether the commands work.

You should be able to explain **why each component exists and how data flows between them**.
