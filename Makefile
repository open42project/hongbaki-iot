SHELL := /bin/bash

.PHONY: \
	task1 stop1 clean1 status1 \
	task2 stop2 clean2 status2 \
	task3 stop3 clean3 status3 \
	argocd-ui argocd-password

# --------------------------------------------------
# Part 1
# --------------------------------------------------

task1:
	cd p1 && vagrant up

stop1:
	cd p1 && vagrant halt

clean1:
	cd p1 && vagrant destroy -f

status1:
	@echo "=== Part 1 Vagrant ==="
	cd p1 && vagrant status


# --------------------------------------------------
# Part 2
# --------------------------------------------------

task2:
	cd p2 && vagrant up

stop2:
	cd p2 && vagrant halt

clean2:
	cd p2 && vagrant destroy -f

status2:
	@echo "=== Part 2 Vagrant ==="
	cd p2 && vagrant status


# --------------------------------------------------
# Part 3
# --------------------------------------------------

task3:
	@echo "==> Checking Docker..."
	@docker --version
	@docker info >/dev/null

	@echo "==> Checking K3d..."
	@if ! command -v k3d >/dev/null 2>&1; then \
		curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; \
	fi

	@echo "==> Checking kubectl..."
	@if ! command -v kubectl >/dev/null 2>&1; then \
		sudo snap install kubectl --classic; \
	fi

	@echo "==> Creating K3d cluster..."
	@if ! k3d cluster list | grep -q '^iot '; then \
		k3d cluster create iot; \
	else \
		echo "K3d cluster 'iot' already exists"; \
	fi

	@echo "==> Creating namespaces..."
	@kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -

	@echo "==> Installing Argo CD..."
	@kubectl apply --server-side --force-conflicts \
		-n argocd \
		-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

	@echo "==> Waiting for Argo CD..."
	@kubectl wait \
		--for=condition=Ready \
		pods \
		--all \
		-n argocd \
		--timeout=300s

	@kubectl get pods -n argocd

stop3:
	k3d cluster stop iot

clean3:
	k3d cluster delete iot

status3:
	@echo "=== K3d ==="
	@k3d cluster list
	@echo ""
	@echo "=== Nodes ==="
	@kubectl get nodes
	@echo ""
	@echo "=== Namespaces ==="
	@kubectl get namespaces
	@echo ""
	@echo "=== Argo CD ==="
	@kubectl get pods -n argocd
	@echo ""
	@echo "=== Dev ==="
	@kubectl get all -n dev

argocd-ui:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd-password:
	@kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d
	@echo
