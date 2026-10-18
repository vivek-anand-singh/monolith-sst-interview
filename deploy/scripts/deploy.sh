#!/usr/bin/env bash
# Builds the image for the current commit, loads it into kind and installs/upgrades the chart.
# --atomic: if the new pods never become Ready the release is rolled back automatically.
#   usage: deploy.sh [namespace]
set -euo pipefail
cd "$(dirname "$0")/../.."

NAMESPACE=${1:-default}
SHA=$(git rev-parse HEAD)
IMAGE=interview-monolith

if [ -n "$(git status --porcelain)" ]; then
  echo "warning: working tree is dirty; the deployed revision label ($SHA) will not describe the exact code" >&2
fi

DOCKER_BUILDKIT=1 docker build --build-arg GIT_SHA="$SHA" -t "$IMAGE:$SHA" .
kind load docker-image "$IMAGE:$SHA" --name interview

helm upgrade --install interview deploy/helm/interview-monolith \
  --namespace "$NAMESPACE" \
  -f deploy/helm/interview-monolith/values-local.yaml \
  --set image.tag="$SHA" \
  --atomic --wait --timeout 5m

deploy/scripts/smoke-test.sh "$SHA" "$NAMESPACE"
