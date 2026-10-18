#!/usr/bin/env bash
# Builds the image for the current commit, loads it into kind and installs/upgrades the chart.
#   usage: deploy.sh [namespace]
set -euo pipefail
cd "$(dirname "$0")/../.."

NAMESPACE=${1:-default}
SHA=$(git rev-parse HEAD)
IMAGE=interview-monolith

DOCKER_BUILDKIT=1 docker build --build-arg GIT_SHA="$SHA" -t "$IMAGE:$SHA" .
kind load docker-image "$IMAGE:$SHA" --name interview

helm upgrade --install interview deploy/helm/interview-monolith \
  --namespace "$NAMESPACE" \
  -f deploy/helm/interview-monolith/values-local.yaml \
  --set image.tag="$SHA" \
  --wait --timeout 5m
