SHELL := /bin/bash

.PHONY: \
	task1 stop1 clean1 prune1 status1 \
	task2 stop2 clean2 prune2 status2 \
	task3 stop3 clean3 prune3 status3 \
	argocd-ui argocd-password \
	space


# --------------------------------------------------
# General helpers
# --------------------------------------------------

space:
	@echo "=== Disk Usage ==="
	@df -h /
	@echo ""
	@echo "=== Vagrant Data ==="
	@du -sh ~/.vagrant.d 2>/dev/null || true
	@du -sh ~/VirtualBox\ VMs 2>/dev/null || true
	@echo ""
	@echo "=== Docker Data ==="
	@docker system df 2>/dev/null || true


# --------------------------------------------------
# Part 1: K3s + Vagrant
# --------------------------------------------------

task1:
	@echo "==> Starting Part 1..."
	cd p1 && vagrant up

stop1:
	@echo "==> Stopping Part 1 VMs..."
	cd p1 && vagrant halt

clean1:
	@echo "==> Deleting Part 1 VMs..."
	cd p1 && vagrant destroy -f || true

	@echo "==> Removing Part 1 Vagrant state..."
	rm -rf p1/.vagrant

prune1:
	@echo "==> Deleting Part 1 VMs through Vagrant..."
	cd p1 && vagrant destroy -f || true

	@echo "==> Removing Part 1 Vagrant state..."
	rm -rf p1/.vagrant

	@echo "==> Powering off leftover Part 1 VirtualBox VMs..."
	@for vm in hongbakiS hongbakiSW vmS vmSW; do \
		if VBoxManage list vms | grep -q "\"$$vm\""; then \
			echo "Powering off $$vm..."; \
			VBoxManage controlvm "$$vm" poweroff >/dev/null 2>&1 || true; \
		fi; \
	done

	@echo "==> Waiting for VirtualBox locks to clear..."
	@sleep 5

	@echo "==> Unregistering leftover Part 1 VirtualBox VMs..."
	@for vm in hongbakiS hongbakiSW vmS vmSW; do \
		if VBoxManage list vms | grep -q "\"$$vm\""; then \
			echo "Deleting $$vm..."; \
			VBoxManage unregistervm "$$vm" --delete || true; \
		fi; \
	done

	@echo "==> Cleaning stale Vagrant records..."
	vagrant global-status --prune || true

	@echo "==> Removing unused Vagrant boxes..."
	vagrant box prune -f || true

	@echo "==> Cleaning apt cache..."
	sudo apt clean

	@echo ""
	@echo "=== Remaining VirtualBox VMs ==="
	@VBoxManage list vms || true

	@echo ""
	@echo "=== Space after Part 1 cleanup ==="
	@df -h /
	@du -sh ~/.vagrant.d 2>/dev/null || true
	@du -sh ~/VirtualBox\ VMs 2>/dev/null || true

status1:
	@echo "=== Part 1 Vagrant ==="
	cd p1 && vagrant status

	@echo ""
	@echo "=== Registered VirtualBox VMs ==="
	@VBoxManage list vms || true

	@echo ""
	@echo "=== Running VirtualBox VMs ==="
	@VBoxManage list runningvms || true


# --------------------------------------------------
# Part 2: K3s + 3 applications
# --------------------------------------------------

task2:
	@echo "==> Starting Part 2..."
	cd p2 && vagrant up

stop2:
	@echo "==> Stopping Part 2 VM..."
	cd p2 && vagrant halt

clean2:
	@echo "==> Deleting Part 2 VM..."
	cd p2 && vagrant destroy -f || true

	@echo "==> Removing Part 2 Vagrant state..."
	rm -rf p2/.vagrant

prune2:
	@echo "==> Deleting Part 2 VM through Vagrant..."
	cd p2 && vagrant destroy -f || true

	@echo "==> Removing Part 2 Vagrant state..."
	rm -rf p2/.vagrant

	@echo "==> Powering off leftover Part 2 VirtualBox VM..."
	@for vm in hongbakiS vmS; do \
		if VBoxManage list vms | grep -q "\"$$vm\""; then \
			echo "Powering off $$vm..."; \
			VBoxManage controlvm "$$vm" poweroff >/dev/null 2>&1 || true; \
		fi; \
	done

	@echo "==> Waiting for VirtualBox locks to clear..."
	@sleep 5

	@echo "==> Unregistering leftover Part 2 VirtualBox VM..."
	@for vm in hongbakiS vmS; do \
		if VBoxManage list vms | grep -q "\"$$vm\""; then \
			echo "Deleting $$vm..."; \
			VBoxManage unregistervm "$$vm" --delete || true; \
		fi; \
	done

	@echo "==> Cleaning stale Vagrant records..."
	vagrant global-status --prune || true

	@echo "==> Removing unused Vagrant boxes..."
	vagrant box prune -f || true

	@echo "==> Cleaning apt cache..."
	sudo apt clean

	@echo ""
	@echo "=== Remaining VirtualBox VMs ==="
	@VBoxManage list vms || true

	@echo ""
	@echo "=== Space after Part 2 cleanup ==="
	@df -h /
	@du -sh ~/.vagrant.d 2>/dev/null || true
	@du -sh ~/VirtualBox\ VMs 2>/dev/null || true

status2:
	@echo "=== Part 2 Vagrant ==="
	cd p2 && vagrant status

	@echo ""
	@echo "=== Registered VirtualBox VMs ==="
	@VBoxManage list vms || true

	@echo ""
	@echo "=== Running VirtualBox VMs ==="
	@VBoxManage list runningvms || true


# --------------------------------------------------
# Part 3: K3d + Argo CD
# --------------------------------------------------

task3:
	@echo "==> Checking Docker..."
	@docker --version
	@docker info >/dev/null

	@echo "==> Checking K3d..."
	@if ! command -v k3d >/dev/null 2>&1; then \
		echo "K3d not found. Installing..."; \
		curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; \
	else \
		echo "K3d already installed"; \
	fi

	@echo "==> Checking kubectl..."
	@if ! command -v kubectl >/dev/null 2>&1; then \
		echo "kubectl not found. Installing..."; \
		sudo snap install kubectl --classic; \
	else \
		echo "kubectl already installed"; \
	fi

	@echo "==> Checking K3d cluster..."
	@if ! k3d cluster list | grep -q '^iot '; then \
		k3d cluster create iot; \
	else \
		echo "K3d cluster 'iot' already exists"; \
		k3d cluster start iot >/dev/null 2>&1 || true; \
	fi

	@echo "==> Waiting for Kubernetes node..."
	@kubectl wait \
		--for=condition=Ready \
		node/k3d-iot-server-0 \
		--timeout=120s

	@echo "==> Creating namespaces..."
	@kubectl create namespace argocd \
		--dry-run=client -o yaml | kubectl apply -f -

	@kubectl create namespace dev \
		--dry-run=client -o yaml | kubectl apply -f -

	@echo "==> Installing Argo CD..."
	@kubectl apply \
		--server-side \
		--force-conflicts \
		-n argocd \
		-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

	@echo "==> Waiting for Argo CD pods..."
	@kubectl wait \
		--for=condition=Ready \
		pods \
		--all \
		-n argocd \
		--timeout=300s

	@echo "==> Creating Argo CD application..."
	@kubectl apply -f p3/application.yaml

	@echo "==> Waiting for playground deployment..."
	@until kubectl get deployment playground -n dev >/dev/null 2>&1; do \
		sleep 2; \
	done

	@kubectl rollout status \
		deployment/playground \
		-n dev \
		--timeout=180s

	@echo ""
	@echo "=== Part 3 ready ==="
	@kubectl get nodes
	@echo ""
	@kubectl get namespaces
	@echo ""
	@kubectl get pods -n argocd
	@echo ""
	@kubectl get all -n dev


# --------------------------------------------------
# Part 3 helpers
# --------------------------------------------------

stop3:
	@echo "==> Stopping K3d cluster..."
	@k3d cluster stop iot || true

clean3:
	@echo "==> Deleting K3d cluster..."
	@k3d cluster delete iot || true

prune3:
	@echo "==> Deleting K3d cluster..."
	@k3d cluster delete iot || true

	@echo "==> Removing unused Docker data..."
	@docker system prune -a -f || true

	@echo "==> Cleaning apt cache..."
	@sudo apt clean

	@echo ""
	@echo "=== Space after Part 3 cleanup ==="
	@df -h /
	@docker system df 2>/dev/null || true

status3:
	@echo "=== K3d Cluster ==="
	@k3d cluster list || true
	@echo ""

	@echo "=== Kubernetes Nodes ==="
	@kubectl get nodes || true
	@echo ""

	@echo "=== Namespaces ==="
	@kubectl get namespaces || true
	@echo ""

	@echo "=== Argo CD ==="
	@kubectl get pods -n argocd || true
	@echo ""

	@echo "=== Dev Namespace ==="
	@kubectl get all -n dev || true


# --------------------------------------------------
# Argo CD helpers
# --------------------------------------------------

argocd-ui:
	@echo "Argo CD UI:"
	@echo "https://localhost:8080"
	@echo ""
	@echo "Keep this terminal open."
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd-password:
	@echo -n "Argo CD admin password: "
	@kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d
	@echo ""
