Think of Kubernetes like a robot manager for little computer programs.

You tell Kubernetes:

“I want this program running.”

And Kubernetes tries to make sure it is running.

Your project has 3 levels.

Task 1: Two computers talking together

Imagine you have two toy computers.

One is the boss computer:

vmS

The other is the helper computer:

vmSW

You created both with Vagrant.

Vagrant is basically a tool that says:

“Please build me a computer with these settings.”

So instead of manually creating VirtualBox machines, you wrote instructions in a Vagrantfile.

Then Vagrant created them for you.

The first machine had this IP:

192.168.56.110

The second had:

192.168.56.111

The first machine runs K3s as the server/controller.

The second machine runs K3s as a worker/agent.

Very simply:

vmS
Boss
K3s server
192.168.56.110
      |
      |
      v
vmSW
Worker
K3s agent
192.168.56.111

The boss says:

“Hey worker, please run this program.”

And the worker can do the work.

So Task 1 is mainly about learning:

Vagrant
Virtual machines
K3s
Server + Worker
Kubernetes cluster

Your make task1 basically means:

Build/start my two Part 1 computers.

And:

make status1

means:

“Vagrant, tell me whether those computers are running.”

Task 2: One computer, three websites

Task 2 is different.

Now you only need one VM.

Again, Vagrant creates it for you.

Inside that VM you install K3s.

But instead of learning server + worker, now you learn:

“How can Kubernetes run websites?”

You created three applications.

Imagine:

app1
app2
app3

Kubernetes runs them inside little boxes called Pods.

So you might have:

K3s
 |
 +-- Pod -> app1
 |
 +-- Pod -> app2
 |
 +-- Pod -> app2
 |
 +-- Pod -> app2
 |
 +-- Pod -> app3

Why does app2 appear three times?

Because Task 2 specifically asks app2 to have:

3 replicas

Replica just means:

“Make three copies of this app.”

Like having three identical ice cream sellers instead of one because lots of customers might come.

Then you used an Ingress.

Ingress is like a receptionist standing at the front door.

Someone says:

I want app1.com

Ingress says:

“Okay, go to app1.”

Someone says:

I want app2.com

Ingress says:

“Okay, go to app2.”

Something else?

Ingress sends them to app3.

So:

Request
   |
   v
Ingress
   |
   +--> app1.com -> app1
   |
   +--> app2.com -> app2
   |
   +--> anything else -> app3

All of this happens using:

192.168.56.110

So Task 2 teaches you:

Pods
Deployments
Replicas
Services
Ingress

Task 1 was more:

“How do I create a Kubernetes cluster?”

Task 2 is more:

“Okay, now what can I actually do with Kubernetes?”

Task 3: Let GitHub control Kubernetes automatically

Task 3 is the biggest change.

You don't use Vagrant to create extra machines anymore.

You already have your main Ubuntu VM.

Inside that VM you installed:

Docker
K3d
kubectl
Argo CD

Let's go one by one.

Docker

Docker lets you run little isolated computer environments called containers.

Think of containers like lunchboxes.

Each lunchbox contains everything one program needs.

Docker
 |
 +-- container
 +-- container
 +-- container
K3d

K3d uses Docker to create a K3s Kubernetes cluster.

Instead of doing this:

VirtualBox VM
    |
   K3s

like you did earlier, K3d does:

Docker
   |
  K3d
   |
  K3s

You ran:

k3d cluster create iot

And K3d created a Kubernetes cluster called:

iot

That's why Docker showed:

k3d-iot-server-0
k3d-iot-serverlb

Those Docker containers are running your K3s cluster.

kubectl

Then you installed:

kubectl

kubectl is your remote control for Kubernetes.

You type:

kubectl get nodes

You're asking:

“Kubernetes, show me your computers.”

You type:

kubectl get pods

You're asking:

“Show me the programs you're running.”

You type:

kubectl create namespace dev

You're saying:

“Please create a separate room called dev.”

Namespaces

You created:

argocd
dev

Think of namespaces like rooms in a house.

Kubernetes house
|
+-- argocd room
|
+-- dev room

The argocd room contains Argo CD itself.

The dev room will contain your application.

This separation keeps things organized.

Argo CD

This is probably the most important Task 3 concept.

Argo CD watches GitHub.

Imagine Argo CD is a robot.

You tell it:

“Watch this GitHub folder.”

Your GitHub repo contains something like:

deployment.yaml
service.yaml

Those files say:

“Run this application using version v1.”

Argo CD reads them.

Then Argo CD tells Kubernetes:

“GitHub says we should run v1.”

So Kubernetes runs:

wil42/playground:v1

The flow becomes:

GitHub
   |
   v
Argo CD
   |
   v
Kubernetes
   |
   v
Your application

This idea is called GitOps.

GitHub becomes the source of truth.

The really cool part of Task 3

Suppose your GitHub file contains:

image: wil42/playground:v1

Your application says:

{"status":"ok","message":"v1"}

Then you edit GitHub:

image: wil42/playground:v2

You push that change.

You don't manually tell Kubernetes:

“Please update the app.”

Instead Argo CD notices:

“Hmm, GitHub says v2 now, but Kubernetes is still running v1.”

So Argo CD changes Kubernetes automatically.

Then your application becomes:

{"status":"ok","message":"v2"}

That's the whole magic of Task 3:

Change GitHub
      |
      v
Argo CD notices
      |
      v
Kubernetes updates
      |
      v
v1 becomes v2
So the three tasks together

Think of it like learning to run a restaurant.

Task 1: Build the restaurant and hire a boss and worker.

Vagrant
    ↓
2 VMs
    ↓
K3s server + worker

Task 2: Start serving different foods.

K3s
 ↓
apps
 ↓
services
 ↓
Ingress

Task 3: Let an automatic robot read your recipe book and change the restaurant for you.

GitHub
 ↓
Argo CD
 ↓
Kubernetes
 ↓
App

And that is why the project makes you do them in this order. Task 1 teaches you what a cluster is. Task 2 teaches you how apps live inside the cluster. Task 3 teaches you how Git can automatically control what Kubernetes runs.
