#!/usr/bin/env bash
# Rolls the release back (to the previous revision, or to a given one) and verifies what is now running.
#   usage: rollback.sh [revision] [namespace]      revision 0 / omitted = previous
set -euo pipefail
cd "$(dirname "$0")"

REVISION=${1:-0}
NAMESPACE=${2:-interview}

helm rollback interview "$REVISION" --namespace "$NAMESPACE" --wait --timeout 3m
RESTORED_SHA=$(kubectl -n "$NAMESPACE" get deploy interview-monolith -o jsonpath='{.spec.template.spec.containers[0].image}' | cut -d: -f2)
./smoke-test.sh "$RESTORED_SHA" "$NAMESPACE"
