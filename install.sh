#!/bin/bash

set -euo pipefail

echo "🚀 Adding ingress-nginx Helm repo and updating..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "📦 Installing ingress-nginx Helm chart..."
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --wait

echo "⏳ Waiting for ingress-nginx controller pod to become Ready..."
kubectl wait \
  --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "✅ Ingress controller pod is ready."

echo "🌐 Fetching LoadBalancer IP..."
PING_ENDPOINT=""
timeout=120
interval=5
elapsed=0

while [ -z "$PING_ENDPOINT" ]; do
  sleep $interval
  elapsed=$((elapsed + interval))
  PING_ENDPOINT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}" 2>/dev/null || true)

  if [ $elapsed -ge $timeout ]; then
    echo "❌ ERROR: LoadBalancer IP not available after $timeout seconds."
    exit 1
  fi
done

echo "✅ LoadBalancer IP: $PING_ENDPOINT"