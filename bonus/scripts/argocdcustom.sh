#!/usr/bin/env bash

echo "==> Applying Argo CD application manifest..."
kubectl apply -f /home/vmvm/p3/gitlab-application.yaml 

echo "==> Triggering hard refresh for 'playground' application..."
argocd app get playground --refresh --hard

echo "==> Done!"
