# Inception-of-Things

This repository contains my work for the **Inception-of-Things (IoT)** project.

The project is divided into three mandatory parts:

* `p1` — K3s and Vagrant
* `p2` — K3s and three simple applications
* `p3` — K3d and Argo CD

## Connect to the Ubuntu VM

From the student computer, connect to the Ubuntu VM with:

```bash
ssh -p 2222 vm@127.0.0.1
```

This is the normal connection used for Part 1 and Part 2.

## Connect for Part 3

For Part 3, Argo CD is exposed inside the VM on port `8080`.

Connect from the student computer using an SSH tunnel:

```bash
ssh -p 2222 -L 8080:localhost:8080 vm@127.0.0.1
```

After connecting, start the Argo CD port forwarding inside the VM:

```bash
make argocd-ui
```

Then open this address in the browser on the student computer:

```text
https://localhost:8080
```

The default Argo CD username is:

```text
admin
```

To display the initial Argo CD password:

```bash
make argocd-password
```

## Makefile Commands

### Part 1

Start Part 1:

```bash
make task1
```

Check status:

```bash
make status1
```

Stop the Vagrant machines:

```bash
make stop1
```

Delete the Vagrant machines:

```bash
make clean1
```

### Part 2

Start Part 2:

```bash
make task2
```

Check status:

```bash
make status2
```

Stop the Vagrant machine:

```bash
make stop2
```

Delete the Vagrant machine:

```bash
make clean2
```

### Part 3

Set up/start Part 3:

```bash
make task3
```

Check the K3d, Kubernetes, Argo CD, and `dev` namespace status:

```bash
make status3
```

Stop the K3d cluster:

```bash
make stop3
```

Delete the K3d cluster:

```bash
make clean3
```

Start Argo CD port forwarding:

```bash
make argocd-ui
```

Display the Argo CD initial admin password:

```bash
make argocd-password
```

## Useful Part 3 Flow

From the student computer:

```bash
ssh -p 2222 -L 8080:localhost:8080 vm@127.0.0.1
```

Inside the VM:

```bash
cd ~/inception-of-things
make task3
make status3
make argocd-ui
```

Then open:

```text
https://localhost:8080
```

in the student computer's web browser.
