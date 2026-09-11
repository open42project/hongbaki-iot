# --------------------------------------------------
# Bonus: K3d + Argo CD + GitLab v10
# --------------------------------------------------

bonus:
	@echo "==> Installing required packages..."
#	@sudo apt-get update && sudo apt-get install -y snapd

	@echo "==> Installing CLI tools (helm)..."
#	@command -v kubectl >/dev/null 2>&1 || sudo snap install kubectl --classic
#	@command -v k3d >/dev/null 2>&1 || (curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash)
	@command -v helm >/dev/null 2>&1 || (curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash)

	@echo "==> Checking Docker..."
	@docker info >/dev/null

	@echo "==> Provisioning K3d cluster 'iot'..."
	@k3d cluster list | grep -q '^iot ' || k3d cluster create iot -p "8080:80@loadbalancer" -p "8443:443@loadbalancer"
	@k3d cluster start iot >/dev/null 2>&1 || true
	@kubectl wait --for=condition=Ready node/k3d-iot-server-0 --timeout=120s

	@echo "==> Creating namespaces..."
	@kubectl apply -f gitlab/namespace.yaml

	@echo "==> Deploying GitLab dependencies (Postgres, Redis, MinIO)..."
	@kubectl apply -f gitlab/postgres.yaml
	@kubectl apply -f gitlab/redis.yaml
	@kubectl apply -f gitlab/minio.yaml
	@kubectl wait --for=condition=Ready pod/postgres -n gitlab --timeout=120s
	@kubectl wait --for=condition=Ready pod/redis -n gitlab --timeout=120s
	@kubectl wait --for=condition=Ready pod/minio -n gitlab --timeout=120s

	@echo "==> Deploying GitLab Chart..."
	@helm repo add gitlab https://charts.gitlab.io 2>/dev/null || true
	@helm repo update
	@helm upgrade --install gitlab gitlab/gitlab \
		--namespace gitlab \
		--values gitlab/values.yaml \
		--timeout 15m

	@echo "==> Waiting for GitLab pods to be Ready or Completed..."
	@kubectl wait --for=condition=Ready pods --all -n gitlab --timeout=300s 2>/dev/null || \
	kubectl get pods -n gitlab --no-headers | awk '{print $$1, $$3}' | while read pod status; do \
		if [ "$$status" != "Completed" ] && [ "$$status" != "Running" ]; then \
			kubectl wait --for=condition=Ready pod/$$pod -n gitlab --timeout=10s 2>/dev/null || true; \
		fi; \
	done

	@echo ""
	@echo "=== Cluster Nodes ==="
	@kubectl get nodes
	@echo ""
	@echo "=== Namespaces ==="
	@kubectl get namespaces
	@echo ""
	@echo "=== GitLab Pods ==="
	@kubectl get pods -n gitlab


	@echo ""
	@echo "=== Part 3 Ready ==="
	@echo "GitLab URL: http://localhost:8888"

bonus-check:
	@set -e; \
	echo "==> Checking Bonus..."; \
	docker info >/dev/null; \
	k3d cluster list | grep -q '^iot '; \
	kubectl cluster-info >/dev/null; \
	kubectl wait --for=condition=Ready node/k3d-iot-server-0 --timeout=30s; \
	kubectl wait --for=condition=Ready pods --all -n argocd --timeout=120s; \
	kubectl wait --for=condition=Ready pods --all -n gitlab --timeout=120s; \
	kubectl get application gitlab -n argocd >/dev/null; \
	echo "==> BONUS CHECK PASSED"

bonus-stop:
	@set -e; \
	echo "==> Stopping K3d..."; \
	k3d cluster stop iot; \
	echo "==> BONUS STOP PASSED"

bonus-clean:
	@set -e; \
	echo "==> Deleting K3d..."; \
	k3d cluster delete iot; \
	echo "==> BONUS CLEAN PASSED"

bonus-prune:
	@set -e; \
	echo "==> Removing K3d..."; \
	k3d cluster delete iot 2>/dev/null || true; \
	echo "==> Cleaning Docker..."; \
	docker system prune -a --volumes -f; \
	echo "==> Cleaning apt..."; \
	sudo apt-get autoremove -y -qq; \
	sudo apt clean; \
	echo "==> Verifying cleanup..."; \
	! k3d cluster list | grep -q '^iot '; \
	echo "==> BONUS PRUNE PASSED"

bonus-status:
	@echo "=== K3d ==="; \
	k3d cluster list; \
	echo "=== Argo CD ==="; \
	kubectl get pods -n argocd; \
	echo "=== GitLab ==="; \
	kubectl get pods -n gitlab; \
	echo "=== Application ==="; \
	kubectl get application -n argocd

bonus-gitlab-ui:
	@echo "GitLab: http://localhost:8888"; \
	kubectl port-forward svc/gitlab-webservice-default -n gitlab 8888:8181 --address 0.0.0.0
	@echo "GitLab SSH: Forwarding port 22...to make ssh available for the gitlab"
	sudo KUBECONFIG=$$HOME/.kube/config kubectl port-forward svc/gitlab-gitlab-shell -n gitlab 22:22 --address 0.0.0.0

bonus-gitlab-password:
	@echo -n "GitLab root password: "; \
	kubectl -n gitlab get secret gitlab-gitlab-initial-root-password \
		-o jsonpath="{.data.password}" | base64 -d; \
	echo ""

bonus-gitlab-status:
	@echo "=== Pods ==="; \
	kubectl get pods -n gitlab; \
	echo "=== Services ==="; \
	kubectl get svc -n gitlab; \
	echo "=== Ingress ==="; \
	kubectl get ingress -n gitlab; \
	echo "=== Argo Application ==="; \
	kubectl get application gitlab -n argocd
