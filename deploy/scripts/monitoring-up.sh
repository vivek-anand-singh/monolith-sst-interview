#!/usr/bin/env bash
# Installs Prometheus, Alertmanager, Grafana (kube-prometheus-stack) and Tempo into the `monitoring` namespace.
set -euo pipefail
cd "$(dirname "$0")/../monitoring"

STACK_VERSION=92.10.1
TEMPO_VERSION=1.24.4

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo update >/dev/null

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Random admin password generated once; read it with the command printed below.
if ! kubectl -n monitoring get secret grafana-admin >/dev/null 2>&1; then
  kubectl -n monitoring create secret generic grafana-admin \
    --from-literal=admin-user=admin --from-literal=admin-password="$(openssl rand -base64 18)"
fi

helm upgrade --install tempo grafana/tempo -n monitoring --version "$TEMPO_VERSION" -f tempo-values.yaml --wait --timeout 5m
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring \
  --version "$STACK_VERSION" -f kube-prometheus-stack-values.yaml --wait --timeout 10m

cat <<MSG

Grafana:      kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80   (http://localhost:3000)
  password:   kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d
Prometheus:   kubectl -n monitoring port-forward svc/monitoring-prometheus 9090
Alertmanager: kubectl -n monitoring port-forward svc/monitoring-alertmanager 9093
MSG
