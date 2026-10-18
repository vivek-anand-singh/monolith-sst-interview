#!/usr/bin/env bash
# Creates the local kind cluster with an ingress controller and metrics-server (needed for the HPA).
set -euo pipefail
cd "$(dirname "$0")/.."

INGRESS_NGINX_VERSION=controller-v1.12.1
METRICS_SERVER_VERSION=v0.7.2

kind get clusters | grep -qx interview || kind create cluster --config kind/kind-config.yaml

kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/kind/deploy.yaml"
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
# kind's kubelet uses a self-signed certificate.
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s
kubectl -n kube-system rollout status deployment/metrics-server --timeout=120s
